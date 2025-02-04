import os
import sys
import torch
import tensorflow as tf

# 添加当前目录到Python路径
current_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.append(current_dir)

from model import UnetGenerator

def replace_leaky_relu_with_relu(model):
    """将模型中的LeakyReLU替换为ReLU"""
    for name, module in model.named_children():
        if isinstance(module, torch.nn.LeakyReLU):
            setattr(model, name, torch.nn.ReLU(inplace=module.inplace))
        else:
            replace_leaky_relu_with_relu(module)

def create_model():
    model = UnetGenerator(input_nc=3, output_nc=1, num_downs=8, ngf=64, norm_layer=torch.nn.InstanceNorm2d, use_dropout=False)
    return model

def convert_to_tflite():
    # 创建模型
    model = create_model()
    
    # 加载预训练权重
    state_dict = torch.load('weights/netG.pth', map_location='cpu')
    # 处理权重键名
    for key in list(state_dict.keys()):
        if 'module.' in key:
            state_dict[key.replace('module.', '')] = state_dict[key]
            del state_dict[key]
    model.load_state_dict(state_dict)
    
    # 替换LeakyReLU为ReLU
    replace_leaky_relu_with_relu(model)
    model.eval()
    
    # 创建示例输入
    example_input = torch.randn(1, 3, 512, 512)
    
    # 导出为ONNX
    torch.onnx.export(model, example_input, 'model.onnx',
                     input_names=['input'],
                     output_names=['output'],
                     dynamic_axes={'input': {0: 'batch_size'},
                                 'output': {0: 'batch_size'}})
    
    # 转换为TensorFlow
    import onnx
    from onnx_tf.backend import prepare
    
    onnx_model = onnx.load('model.onnx')
    tf_rep = prepare(onnx_model)
    
    # 保存为SavedModel格式
    tf_rep.export_graph('saved_model')
    
    # 转换为TFLite
    converter = tf.lite.TFLiteConverter.from_saved_model('saved_model')
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float32]
    tflite_model = converter.convert()
    
    # 保存TFLite模型
    with open('model.tflite', 'wb') as f:
        f.write(tflite_model)

if __name__ == '__main__':
    convert_to_tflite()
