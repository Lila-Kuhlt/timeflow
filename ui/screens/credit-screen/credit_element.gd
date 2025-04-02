class_name CreditButton
extends VBoxContainer

var credit: CreditEntry

func set_credit(credit_entry: CreditEntry) -> void:
	credit = credit_entry
	if credit.descriptor:
		$DescribtorLabel.text = credit.descriptor
	$CreditButton.text = credit.name
	
	if credit.license:
		$CreditButton.tooltip_text = credit.license
	if credit.url:
		$CreditButton.pressed.connect(open_url)

func open_url():
	OS.shell_open(credit.url)
