extends RefCounted
class_name MenuDetailState
## 菜单状态数据，用于记录各个菜单的设置状态，如新建题纸菜单的模式是沙盒还是解题
## 使用时需要将本类实例化为一个实例使用

## 本类所记录的参数均代表菜单选项的保存，任何情况都不应该将本类记录的参数用作有关核心系统的逻辑中
## 当某个菜单选项从设计上需要直接关联于本游戏核心系统的特定状态，则该选项不应从本类中存取数据，而是依赖于Main(例如底部菜单的自动填充选项)

## 游戏模式(只用于菜单，和Main.GameMode无关)
enum GameMode{
	PUZZLE, #解题
	SANDBOX, #沙盒
}

## 弹出菜单-新建题纸.游戏模式
var popup_newpaper_mode: GameMode = GameMode.PUZZLE
## 弹出菜单-新建题纸.尺寸
var popup_newpaper_size: Vector2i = Vector2i(5, 5)
## 弹出菜单-新建题纸.种子
var popup_newpaper_seed: String = ""
