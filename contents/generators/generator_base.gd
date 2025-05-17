extends RefCounted
class_name Generator
## 局面生成器基类。编写生成器时需要继承此类

## 以下是一段生成器介绍模板，每个生成器子类都要在开头包含一个这样的小文档

## 生成器逻辑：
## 	<描述生成器的大致思路>
## 随机算法：
## 	<描述生成器使用何种现成的随机算法或随机器，例如Godot自带的随机器。若算法有自己的原因不便描述或没有使用随机器，可以写"无">
## 生成器参数：
## 	必要参数：
## 		EX(Example):
## 			一个必要参数示例。
## 			该参数的其余描述
## 	可选参数：
## 		OP(Optional) = <默认值>:
## 			一个可选参数示例。
## 			该参数的其余描述。

## [虚函数-声明]种子前缀匹配检查方法，检查输入的种子前缀是否属于本生成器(对于空前缀应当返回false)
static func _is_seed_prefix_matched(seed_prefix: StringName) -> bool:
	return seed_prefix == &"BASE" #基类这里作示范，假设了基类的种子前缀为&"BASE"

## [虚函数-声明]种子可用性检查方法(含前缀)，检查输入的种子对于本生成器来说是否合法
## 本方法应设计为种子合法性检查流程的最后一道门槛，在此方法之前，种子必定已经通过_is_seed_prefix_matched()的前缀检查，所以可以不用担心性能消耗
#static func _is_seed_valid(seed: String) -> bool:
#	return false

## [虚函数-声明]种子参数可用性检查方法(传入一个SeedParser反序列化好的参数字典)，检查输入的种子参数对于本生成器来说是否可用
## 本方法旨在检查给定的参数是否满足本生成器所需的必要参数，同时值也满足本生成器接受的值
static func _is_seed_parameters_usable(parameters: Dictionary) -> bool:
	return false

## [虚函数-声明]生成题目局面数据
static func _generate(seed_deserializated: SeedParser.SeedDeserializated, size: Vector2i) -> GridsData:
	return null
