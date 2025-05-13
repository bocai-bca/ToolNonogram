extends Generator
class_name Generator_RainingPick
## 局面生成器-雨滴选取
## 生成器逻辑：
## 	在生成之前获取一个约为题纸

## [虚函数-实现]种子前缀匹配检查方法
static func _is_seed_prefix_matched(seed_prefix: StringName) -> bool:
	return seed_prefix == &"RP"

## [虚函数-实现]种子参数可用性检查方法(只能输入种子)，检查输入的种子参数对于本生成器来说是否可用
static func _is_seed_parameters_usable(parameters: Dictionary) -> bool:
	return true

## [虚函数-实现]生成题目局面数据
static func _generate(seed_deserializated: SeedParser.SeedDeserializated, size: Vector2i) -> GridsData:
	var result: GridsData = GridsData.new(size)
	return result
