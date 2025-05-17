extends Generator
class_name Generator_RainingPick
## 局面生成器-雨滴选取
## 生成器逻辑：
## 	在生成之前通过Total参数获取一个最大尝试次数、通过Target参数获取一个目标成功次数，然后对整个局面进行随机抽取，每次抽取时累积一个一级尝试次数。
## 	当抽取到一个未被填充的格子时会将该格子填充；当抽取到一个已填充的格子时会开启二级抽取模式，在二级抽取模式下会累积一个二级抽取次数并进行一次抽取(不累积一级尝试次数)，抽取到未填充的格子时会填充该格子并结束二级抽取模式，若在该次二级抽取模式中二级抽取次数达到二级抽取最大次数，将结束二级抽取模式。
## 	当填充格子的次数达到目标成功次数后，生成器将停止；但若一级尝试次数达到最大尝试次数，无论填充格子次数有没有达到目标成功次数，生成器都将停止。
## 随机算法：
## 	使用Godot提供的随机器
## 生成器参数：
## 	必要参数：
## 		无
## 	可选参数：(等于号后面是默认值)
## 		M(Max) = 120:
## 			总尝试次数乘数。
## 			本参数相当于一个百分比数，乘上网格总格子数，按进一法得到总尝试次数。
## 			一级抽取次数达到此次数会使生成器立即停止。
## 		R(Retry) = 2:
## 			二级抽取最大次数。
## 			在一次一级抽取时如果选中了已填充的格子，将在此基础上再次二级重抽(有可能还是抽中该格子)。
## 		T(Target) = 80:
## 			目标成功次数乘数。
## 			本参数相当于一个百分比数，乘上网格总格子数，按进一法得到总尝试次数。
## 			成功次数达到此次数会使生成器立即停止。

## 默认总尝试次数乘数(对应参数M)
const DEFAULT_MAX_TRY: float = 1.4
## 默认二级抽取最大次数(对应参数R)
const DEFAULT_MAX_RETRY: int = 2
## 默认目标成功次数乘数(对应参数T)
const DEFAULT_TARGET: float = 0.6

## [虚函数-实现]种子前缀匹配检查方法
static func _is_seed_prefix_matched(seed_prefix: StringName) -> bool:
	return seed_prefix == &"RP"

## [虚函数-实现]种子参数可用性检查方法(只能输入种子)，检查输入的种子参数对于本生成器来说是否可用
static func _is_seed_parameters_usable(parameters: Dictionary) -> bool:
	return true

## [虚函数-实现]生成题目局面数据
static func _generate(seed_deserializated: SeedParser.SeedDeserializated, size: Vector2i) -> GridsData:
	print("Generator_RainingPick: 生成器启动")
	var result: GridsData = GridsData.new(size)
	## 00参数设置和初始化
	var max_try: int = ceili(DEFAULT_MAX_TRY * float(size.x * size.y)) #最大尝试次数
	var target_success: int = ceili(DEFAULT_TARGET * float(size.x * size.y)) #目标成功次数
	var max_retry: int = DEFAULT_MAX_RETRY #最大二级抽取次数
	var current_try: int = 0 #当前已尝试次数
	var current_retry: int #当前二级抽取次数
	var current_success: int = 0 #当前成功次数
	seed(seed_deserializated.seed_number) #设置Godot随机器种子
	if (seed_deserializated.parameters.has(&"M")): #如果存在参数键M
		max_try = ceili(float(seed_deserializated.parameters[&"M"]) / 100.0 * float(size.x * size.y)) #设置最大尝试次数
		print("Generator_RainingPick: 已使用参数设置最大尝试次数为", str(max_try))
	else: #否则(不存在参数键M)
		print("Generator_RainingPick: 参数最大尝试次数将使用默认值", str(max_try))
	if (seed_deserializated.parameters.has(&"R")): #如果存在参数键R
		max_retry = seed_deserializated.parameters[&"R"] #设置最大二级抽取次数
		print("Generator_RainingPick: 已使用参数设置最大二级抽取次数为", str(max_retry))
	else: #否则(不存在参数键R)
		print("Generator_RainingPick: 参数最大二级抽取次数将使用默认值", str(max_retry))
	if (seed_deserializated.parameters.has(&"T")): #如果存在参数键T
		target_success = ceili(float(seed_deserializated.parameters[&"T"]) / 100.0 * float(size.x * size.y)) #设置目标成功次数
		print("Generator_RainingPick: 已使用参数设置目标成功次数为", str(target_success))
	else: #否则(不存在参数键T)
		print("Generator_RainingPick: 参数目标成功次数将使用默认值", str(target_success))
	var random_slot: Vector2i #随机抽取格子坐标
	## /00
	## 01总循环
	while (current_try < max_try): #当已尝试次数小于最大尝试次数时继续循环
		random_slot = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1)) #随机取得一个格子
		if (result.get_slot(random_slot) == GridsData.SlotType.EMPTY): #如果抽到空格
			result.set_slot(random_slot, GridsData.SlotType.FILL) #将该格子填充
			current_success += 1 #记录成功次数
		else: #否则(抽到填充格)
			## 02二次抽取
			current_retry = 0 #初始化二次抽取次数
			while (current_retry < max_retry): #当二次抽取次数小于最大二次抽取次数时继续循环
				random_slot = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1)) #随机取得一个格子
				if (result.get_slot(random_slot) == GridsData.SlotType.EMPTY): #如果抽到空格
					result.set_slot(random_slot, GridsData.SlotType.FILL) #将该格子填充
					current_success += 1 #记录成功次数
					break #跳出二次抽取
				current_retry += 1 #累积一次二次抽取次数
			## /02
		if (current_success >= target_success): #当成功次数已达标
			break #跳出while
		current_try += 1 #累积一次尝试次数
	## /01
	randomize() #恢复种子随机化
	print("Generator_RainingPick: 生成完毕")
	return result
