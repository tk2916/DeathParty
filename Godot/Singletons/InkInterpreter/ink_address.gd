class_name InkAddress extends RefCounted

var tree : InkTree
var container : InkContainer
var index : int

func _init(_tree : InkTree, _container : InkContainer, _index : int) -> void:
	tree = _tree
	container = _container
	index = _index

func duplicate() -> InkAddress:
	return InkAddress.new(tree, container, index)