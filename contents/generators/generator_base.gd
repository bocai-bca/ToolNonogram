extends RefCounted
class_name Generator
## 局面生成器基类。编写生成器时需要继承此类

## [虚函数-声明]种子前缀匹配检查方法，检查输入的种子前缀是否属于本生成器(对于空前缀应当返回false)
static func _is_seed_prefix_matched(seed_prefix: StringName) -> bool:
	return seed_prefix == &"BASE" #基类这里作示范，假设了基类的种子前缀为&"BASE"

## [虚函数-声明]种子可用性检查方法(含前缀)，检查输入的种子对于本生成器来说是否合法
## 本方法应设计为种子合法性检查流程的最后一道门槛，在此方法之前，种子必定已经通过_is_seed_prefix_matched()的前缀检查，所以可以不用担心性能消耗
static func _is_seed_valid(seed: String) -> bool:
	return false

## [虚函数-声明]生成题目局面数据
static func _generate(seed: String, size: Vector2i) -> GridsData:
	return null
