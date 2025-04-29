extends Object
class_name SeedManager
## 种子管理器，负责生成、解析种子和生成的类

## 检查种子是否合法(面向用户指定的种子)，合法则返回true
static func is_input_valid(seed: String) -> bool:
	if (seed.is_empty()): #如果为空，意味着随机生成种子
		return true
	return false ##没写完
