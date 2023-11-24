VFC_BACKENDS="libinterflop_mca.so" python -c "
import torch
import pickle

N_SAMPLES = 30

torch.manual_seed(0)
a = torch.rand(5, 5)
b = torch.rand(5, 5)

matmul = []
for _ in range(N_SAMPLES):
  matmul.append(a @ b)

m = torch.nn.Linear(20, 30)
a = torch.randn(128, 20)

matmul_layer = []
for _ in range(N_SAMPLES):
  matmul_layer.append(m(a))

filters = torch.randn(8, 4, 3, 3)
inputs = torch.randn(1, 4, 5, 5)

conv = []
for _ in range(N_SAMPLES):
  conv.append(torch.nn.functional.conv2d(inputs, filters, padding=1))

m = torch.nn.Conv2d(16, 33, 3, stride=2)
a = torch.randn(20, 16, 50, 100)

conv_layer = []
for _ in range(N_SAMPLES):
  conv_layer.append(m(a))



with open('fuzzy-pytorch_matmul_results.pickle', 'wb') as file:
  pickle.dump(torch.stack(matmul), file)

with open('fuzzy-pytorch_matmul_layer_results.pickle', 'wb') as file:
  pickle.dump(torch.stack(matmul_layer), file)

with open('fuzzy-pytorch_conv_results.pickle', 'wb') as file:
  pickle.dump(torch.stack(conv), file)

with open('fuzzy-pytorch_conv_layer_results.pickle', 'wb') as file:
  pickle.dump(torch.stack(conv_layer), file)
"
VFC_BACKENDS="libinterflop_ieee.so" python -c "
import torch
import pickle

torch.manual_seed(0)
a = torch.rand(5, 5)
b = torch.rand(5, 5)
correct_res = a @ b

with open('fuzzy-pytorch_matmul_results.pickle', 'rb') as file:
  mca_res = pickle.load(file)

with open('fuzzy-pytorch_matmul_layer_results.pickle', 'rb') as file:
  matmul_layer = pickle.load(file)

with open('fuzzy-pytorch_conv_results.pickle', 'rb') as file:
  conv = pickle.load(file)

with open('fuzzy-pytorch_conv_layer_results.pickle', 'rb') as file:
  conv_layer = pickle.load(file)

mean_res = mca_res.mean(dim=0)
relative_errors = (mean_res - correct_res) / correct_res
print('Relative errors: ')
print(relative_errors)

assert torch.allclose(mean_res, correct_res), 'Results of matrix multiplication with MCA not centered on the correct result'
print('[PASSED] Results of matrix multiplication with MCA centered on the correct result')

assert mca_res.std(dim=0).sum() != 0, 'Results of matrix multiplication with MCA are deterministic'
print('[PASSED] Results of matrix multiplication with MCA are not deterministic')

assert matmul_layer.std(dim=0).sum() != 0, 'Results of Linear layer matrix multiplication with MCA are deterministic'
print('[PASSED] Results of Linear layer matrix multiplication with MCA are not deterministic')

assert conv.std(dim=0).sum() != 0, 'Results of convolution operation with MCA are deterministic'
print('[PASSED] Results of convolution with MCA are not deterministic')

assert conv_layer.std(dim=0).sum() != 0, 'Results of Convolution layer with MCA are deterministic'
print('[PASSED] Results of Convolution layer with MCA are not deterministic')

"
