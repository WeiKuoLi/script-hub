import numpy as np
import matplotlib.pyplot as plt
x = np.linspace(-20,20,100)
y = np.exp(-x**2/25.)
plt.plot(x,y)
plt.show()
plt.savefig('1.jpg')
