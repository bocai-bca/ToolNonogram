extends RefCounted
class_name SeedParser
## 种子解析器

## 关于种子：
## 	种子是生成数织题目的途径之一，生成器是接受种子并创建题目的算法。
## 	种子为一个String，只能含有0-9数字、A-Z大写字母(小写字母设计上允许，但需要在访问本类之前对种子进行大写转换)，当存在这些以外的符号时，该种子将被视为不合法。
## 	一个种子由以下格式构成：
## 			<前缀>[<种子数>][<参数串>]
## 		前缀：
## 			由纯英文字母组成，表达该种子所使用的生成器。
## 			目前设计为前缀不允许省略，虽然说有考虑实现"默认生成器"的功能，以后再看吧，可以改为允许省略前缀。
## 		种子数：
## 			(当不存在时系统将随机生成一个int64以用作种子数)
## 			此处需填写一个十进制正整数，该数字将在代码中被转换到int64，因此会出现诸如以下状况(包括但不限于)：
## 				- 前导0将被无视
## 				- 超出int64上限的数字将"绕回"或截断，详情请参考Godot的Int类型说明
## 			种子数会由上游代码提交给生成器，具体作何行为由生成器决定，通常会用作随机发生器种子。
## 		参数串：
## 			(当不存在时系统不会采取措施，通常来说本部分是可选的，但可能有个别生成器会要求必须包含参数串甚至特定参数)
## 			参数串中可以包含多个参数，参数是给生成器使用的追加信息，生成器将通过参数键来索引到参数，具体怎么填写需要视生成器而定。
## 			参数之间不需要使用任何符号分隔。
## 			每个参数的格式是：
## 					<参数键><参数值>
## 				参数键：
## 					类似前缀，由纯英文字母组成，表示此参数的键名。
## 				参数值：
## 					类似种子数，为一个十进制正整数，处理方式与种子数相同。

## 种子验证流程：
## 	一个种子的合法验证具有以下步骤，按步骤逐步往下检查可以随时退出以避免浪费性能：
## 		("静态"代表可以由解析器自己静态判断，无需依赖外部；"动态"代表解析器需要访问外界数据，如将内容提交给生成器并接收回复)
## 		1.[静态]字符合法性检查
## 		2.[动态]前缀可用性检查
## 		3.[静态]数字合法性检查
## 		4.[静态]参数合法性检查
## 		5.[动态]参数可用性检查

## 种子分段类型
enum SeedFragmentType{
	NAME, #由纯英文字母组成的分段，符合SEED_NAME_CHAR数组
	NUMBER, #由纯数字组成的分段，符合SEED_NUMBER_CHAR数组
}

## 种子合法数字字符表，用于数字和参数值
const SEED_NUMBER_CHAR: PackedStringArray = [
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
]
## 种子合法字母字符表，用于前缀和参数键
## 理论上允许用户输入小写字母，但是需要在检查之前将小写字母转换到大写字母，此步骤需要在访问本类之前就完成
const SEED_NAME_CHAR: PackedStringArray = [
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
]

## 种子验证的完全抽象，涵盖每一步动作。只需要将需要验证的种子传进去即可得到最终结果，请勿高频调用此方法以免加剧性能消耗。为true意味着该种子合法且可用
## 可以在第二个参数处传入一个SeedDeserializated实例，本方法会将反序列化好的种子通过这种方式传出去。即便返回结果为false，该SeedDeserializated仍有可能被写入值
## 本方法将视空种子为不合法种子，对于使用空种子以进行随机生成的游戏系统设计功能，相关逻辑请在PuzzleManager中实现
## 本方法内部会调用本类的其他方法
static func fully_seed_check(seed: String, seed_deserializated: SeedDeserializated = SeedDeserializated.new(null, 0, {})) -> bool:
	if (seed.is_empty()): #如果种子为空
		return false #因结构不合法(种子为空)返回false
	## 00字符合法性检查
	var seed_splitted: Array[SeedFragment] = seed_splitting(seed) #获取种子分段
	if (seed_splitted.is_empty()): #如果种子分段列表为空，意味着种子分段方法报告其存在不合法的符号
		return false #因字符不合法返回false
	## /00
	## 01前缀可用性检查
	if (seed_splitted[0].value.is_empty()): #如果种子分段列表的首项的值是空的，意味着未指定生成器
		return false #因结构不合法(前缀为空)返回false
	var generator_matched: Generator = PuzzleManager.find_generator_by_prefix(seed_splitted[0].value) #调用PuzzleManager提供的方法，使用前缀寻找匹配的生成器
	if (generator_matched == null): #如果该变量为null，意味着没有任何生成器匹配，意味着前缀不可用
		return false #因前缀不可用返回false
	seed_deserializated.generator = generator_matched #将已匹配的生成器放进反序列化种子实例
	## /01
	## 02数字合法性检查
	if (seed_splitted.size() >= 2): #如果分段数大于等于2
		if (not seed_splitted[1].value.is_valid_int()): #如果第二分段不是合法的int64
			return false #因数字不合法返回false
	else: #否则(只有前缀分段)
		return false #因结构不合法(种子数为空)返回false
	seed_deserializated.seed_number = seed_splitted[1].value.to_int() #将种子数转换为int后存储进反序列化种子实例
	## /02
	## 03参数合法性检查，只需要检查参数的键与值是否成对即可
	if (seed_splitted.size() % 2 != 0): #如果分段数量求余2不等于0，也就是说分段数量不是偶数
		return false #因结构不合法(参数键值不成对)返回false
	## /03
	## 04参数可用性检查，需要访问生成器
	## 	05参数解析
	for i in (seed_splitted.size() / 2 - 1): #按索引以两倍焦点减1遍历分段列表
		i += 1 #减1的目的是为了跳过首两个片段，所以这里还要把这个1加回去
		seed_deserializated.parameters[StringName(seed_splitted[i].value)] = seed_splitted[i + 1].value.to_int() #太复杂了懒得讲
	## 	/05
	if (not generator_matched._is_seed_parameters_usable(seed_deserializated.parameters)): #将解析后的参数字典传进生成器的参数可用性检查方法，如果返回的结果不是可用的
		return false #因参数不可用返回false
	## /04
	return true #活到现在就是可用，返回true

## 种子分段方法，主要功能为将种子分段成存储SeedFragment的数组，同时将检查符号合法性，当出现不合法的符号时，本方法将会返回空数组
## 本方法不会检查结构合法性和种子可用性
## 本方法只认同SEED_NUMBER_CHAR字符表和SEED_NAME_CHAR字符表，也就是说本方法不认可小写字母，如需支持小写字母需在种子传入本方法之前将其大写化
static func seed_splitting(seed: String) -> Array[SeedFragment]:
	var current_type: SeedFragmentType = SeedFragmentType.NAME #声明局部变量，记录当前的字符类型。NAME对应字母，NUMBER对应数字
	var result_array: Array[SeedFragment] = [] #声明局部变量，为结果列表
	var fragment_string: String = "" #声明局部变量，记录当前片段的字符串
	for char in seed: #遍历每个字符
		if (SEED_NAME_CHAR.has(char)): #如果当前字符包含于字母表
			match (current_type): #匹配当前类型
				SeedFragmentType.NAME: #为字母查找状态
					fragment_string += char #将当前字符加入当前片段，然后继续下一个字符
					continue
				SeedFragmentType.NUMBER: #为数字查找状态
					## 在数字查找状态下找到了字母，意味着要切模式了
					result_array.append(SeedFragment.new(current_type, fragment_string)) #创建一个新SeedFragment实例并添加到结果数组中
					current_type = SeedFragmentType.NAME #将当前字符查找类型改为字母查找状态
					fragment_string = char #将当前片段设为当前字符，相当于清空当前片段后再追加当前字符
		elif (SEED_NUMBER_CHAR.has(char)): #否则如果当前字符包含于数字表
			match (current_type): #匹配当前类型
				SeedFragmentType.NAME: #为字母查找状态
					## 在字母查找状态下找到了数字，意味着要切模式了
					result_array.append(SeedFragment.new(current_type, fragment_string)) #创建一个新SeedFragment实例并添加到结果数组中
					current_type = SeedFragmentType.NUMBER #将当前字符查找类型改为数字查找状态
					fragment_string = char #将当前片段设为当前字符，相当于清空当前片段后再追加当前字符
				SeedFragmentType.NUMBER: #为数字查找状态
					fragment_string += char #将当前字符加入当前片段，然后继续下一个字符
					continue
		else: #否则(当前字符既不包含于字母表也不包含于数字表，属于非法字符)
			return [] #因非法字符而种子不合法，所以返回空数组
	return result_array #返回结果

## 获取种子的前缀
## 本方法可能将会弃用
static func get_seed_prefix(seed: String) -> StringName:
	var result: String = ""
	for char in seed: #遍历字符串的每个字符
		if (char.is_valid_int()): #如果本字符是数字
			break #退出for
		else: #否则(本字符不是数字)
			result += char #将本字符加进result
	return StringName(result.to_upper()) #将result转为大写后转为StringName后返回

## 类-种子分段，由seed_deserialization()方法创建的种子分段列表必定是合法的，但不保证可用
class SeedFragment extends RefCounted:
	## 分段类型
	var type: SeedFragmentType
	## 值
	var value: String
	func _init(new_type: SeedFragmentType, new_value: String) -> void:
		type = new_type
		value = new_value

## 类-反序列化种子，是种子解析流程的最终产品
class SeedDeserializated extends RefCounted:
	## 种子所使用的生成器实例
	var generator: Generator
	## 种子数
	var seed_number: int
	## 种子参数
	var parameters: Dictionary[StringName, int]
	func _init(new_generator: Generator, new_seed_number: int, new_parameters: Dictionary[StringName, int]) -> void:
		generator = new_generator
		seed_number = new_seed_number
		parameters = new_parameters
