extends PanelContainer
class_name DetailPopupBase
## 详细信息弹窗基类。一种一次性的弹窗

## 目前需要设计它的实例化方案，有两种选择：
## 	1.通过PackedScene资源生成固定的弹窗 √
## 	2.通过代码中的数组记录数据然后自己实现构造方法

## 弹出菜单场景，通过弹出菜单名索引该字典可获得一个PackedScene，将该PackedScene实例化即可
const POPUP_MENU_SCENES: Dictionary[StringName, PackedScene] = {
	&"Menu_Paper_New": preload("res://contents/detail_popup/detail_popup_menu_paper_new.tscn"), #菜单.题纸.新建
}

## 菜单禁用，为true时整个菜单的交互会被禁用，用于需要让用户等待而暂时阻止用户对菜单进行交互的时候，或者是菜单打开或关闭的期间。关于本属性的具体效果实现需要在子类中手动实现
var disabled: bool = false
