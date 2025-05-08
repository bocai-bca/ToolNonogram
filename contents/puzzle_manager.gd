extends Object
class_name PuzzleManager
## 谜题管理器。
## 提供了一系列静态方法的类，涵盖于生成和解析种子、用多种途径创建谜题和检查通关的类

## 检查种子是否合法(面向用户指定的种子)，合法则返回true(种子为空时也合法)
static func is_seed_valid(seed: String) -> bool:
	if (seed.is_empty()): #如果为空，意味着随机生成种子
		return true
	return false ##没写完
