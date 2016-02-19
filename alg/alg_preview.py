import sys
import os
sys.path.append(os.getcwd() + '/alglib')

AF_PATH      = os.environ['AF_PATH']
afDataInPath = os.path.join(AF_PATH,'data','in')

print(afDataInPath)
