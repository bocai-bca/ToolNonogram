extends RefCounted
class_name PuzzleManager
## 谜题管理器。
## 提供了一系列静态方法的类，涵盖于生成和解析种子、用多种途径创建谜题和检查通关的类

## 关于种子：
## 	种子是生成数织题目的途径之一，生成器是接受种子并创建题目的算法。
## 	种子为一个String，只能含有0-9数字、a-z小写字母、A-Z大写字母，当存在这些以外的符号时，该种子将被视为不合法。
## 	一个种子由以下格式构成：
## 			<前缀>[<种子串>][<参数串>]
## 		前缀：
## 			由纯英文字母组成，表达该种子所使用的生成器。
## 		种子串：
## 			(当不存在时系统将随机生成一个int64以用作种子串)
## 			此处需填写一个十进制正整数，该数字将在代码中被转换到int64，因此会出现诸如以下状况(包括但不限于)：
## 				- 前导0将被无视
## 				- 超出int64上限的数字将被认为不合法
## 			种子串会由上游代码提交给生成器，具体作何行为由生成器决定，通常会用作随机发生器种子。
## 		参数串：
## 			(当不存在时系统不会采取措施，通常来说本部分是可选的，但可能有个别生成器会要求必须包含参数串甚至特定参数)
## 			参数串中可以包含多个参数，参数是给生成器使用的追加信息，生成器将通过参数键来索引到参数，具体怎么填写需要视生成器而定。
## 			参数之间不需要使用任何符号分隔。
## 			每个参数的格式是：
## 					<参数键><参数值>
## 				参数键：
## 					类似前缀，由纯英文字母组成，表示此参数的键名。
## 				参数值：
## 					类似种子串，为一个十进制正整数，处理方式与种子串相同。

## [只读]存放一堆生成器的实例(别放基类)
static var generators: Array[Generator] = [
	Generator_RandomPick.new(), #随机选取
]

## 获取种子的前缀
static func get_seed_prefix(seed: String) -> StringName:
	var result: String = ""
	for char in seed: #遍历字符串的每个字符
		if (char.is_valid_int()): #如果本字符是数字
			break #退出for
		else: #否则(本字符不是数字)
			result += char #将本字符加进result
	return StringName(result.to_upper()) #将result转为大写后转为StringName后返回

## 检查种子是否合法(面向用户指定的种子)，合法则返回true(种子为空时也合法)
## 本方法内部使用了面向系统的合法性检查，如果不需要允许空种子可以直接调用is_seed_valid()，以节省性能
static func is_seed_valid_user(seed: String) -> bool:
	if (seed.is_empty()): #如果为空，意味着随机生成种子
		return true
	return is_seed_valid(seed) #直接调用面向系统的种子合法性检查方法并返回结果

## 检查种子是否合法(面向系统)，合法则返回true(理论上种子为空时不合法，除非有生成器在空种子时返回了true，但这是不应该的)
## 本方法内部使用了种子前缀获取方法，请勿传入摘除了前缀的种子
static func is_seed_valid(seed: String) -> bool:
	var seed_prefix: StringName = get_seed_prefix(seed) #获取种子前缀
	for generator in generators: #遍历所有生成器
		if (generator._is_seed_prefix_matched(seed_prefix)): #如果该种子前缀匹配当前生成器
			if (generator._is_seed_valid(seed)): #如果该种子于当前生成器来说合法且可用
				return true
			else: #否则(该种子于当前生成器来说符合前缀但不合法或可用)
				return false
	return false
