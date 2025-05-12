extends RefCounted
class_name PuzzleManager
## 谜题管理器。
## 提供了一系列静态方法的类，涵盖于生成和解析种子、用多种途径创建谜题和检查通关的类

## [只读]存放一堆生成器的实例(别放基类)
static var generators: Array[Generator] = [
	Generator_RainingPick.new(), #随机选取
]
## [只读]默认生成器，当用户没有指定种子时使用什么生成器前缀
static var DEFAULT_GENERATOR_PREFIX: String = "RP" #雨滴选取
## [只读]默认生成器参数，当用户没有指定种子时使用的生成器参数
static var DEFAULT_GENERATOR_PARAMETERS: String = ""

### 检查种子是否合法(面向用户指定的种子)，合法则返回true(种子为空时也合法)
### 本方法内部使用了面向系统的合法性检查，如果不需要允许空种子可以直接调用is_seed_valid()，以节省性能
#static func is_seed_valid_user(seed: String) -> bool:
	#if (seed.is_empty()): #如果为空，意味着随机生成种子
		#return true
	#return is_seed_valid(seed) #直接调用面向系统的种子合法性检查方法并返回结果
#
### 检查种子是否合法(面向系统)，合法则返回true(理论上种子为空时不合法，除非有生成器在空种子时返回了true，但这是不应该的)
### 本方法内部使用了种子前缀获取方法，请勿传入摘除了前缀的种子
#static func is_seed_valid(seed: String) -> bool:
	#var seed_prefix: StringName = get_seed_prefix(seed) #获取种子前缀
	#for generator in generators: #遍历所有生成器
		#if (generator._is_seed_prefix_matched(seed_prefix)): #如果该种子前缀匹配当前生成器
			#if (generator._is_seed_valid(seed)): #如果该种子于当前生成器来说合法且可用
				#return true
			#else: #否则(该种子于当前生成器来说符合前缀但不合法或可用)
				#return false
	#return false

## 随机生成种子
static func random_seed(prefix: String = DEFAULT_GENERATOR_PREFIX, parameters: String = DEFAULT_GENERATOR_PARAMETERS) -> String:
	return prefix + str((randi() << 32 | randi()) & 0x7FFF_FFFF_FFFF_FFFF) + parameters

## 获取种子前缀所代表的生成器(返回一个生成器实例)，当没有任何生成器匹配时将返回null，当有多个生成器可以匹配的情况时只会返回第一个
## 本方法不直接进行判断，判断交由各个生成器进行，如果哪个生成器对于空输入也会作出true回应，那么本方法也将最终返回true
static func find_generator_by_prefix(seed_prefix: String) -> Generator:
	for generator in generators: #遍历所有生成器
		if (generator._is_seed_prefix_matched(seed_prefix)): #如果该种子前缀匹配当前生成器
			return generator #返回当前生成器
	return null #因为没有任何生成器匹配所以返回null
