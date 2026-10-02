@tool
extends RefCounted
## Strings for the P1 viewport tools (grid, nudge, draw, openings, face drag, array).

const STRINGS: Dictionary = {
	"NUDGE_ACTION": {
		"zh": "微调位置", "en": "Nudge", "ja": "位置を微調整", "ko": "위치 미세 조정",
		"es": "Desplazar", "pt": "Ajustar posição", "ru": "Сдвинуть",
	},
	"ROTATE_ACTION": {
		"zh": "旋转", "en": "Rotate", "ja": "回転", "ko": "회전",
		"es": "Rotar", "pt": "Girar", "ru": "Повернуть",
	},
	"DROP_ACTION": {
		"zh": "落到下方表面", "en": "Drop to Surface", "ja": "下の面に落とす", "ko": "아래 표면에 내려놓기",
		"es": "Bajar a la superficie", "pt": "Soltar na superfície", "ru": "Опустить на поверхность",
	},
	"SNAP_SELECTION_TO_GRID": {
		"zh": "选中对齐到栅格", "en": "Snap Selection to Grid", "ja": "選択をグリッドに揃える", "ko": "선택 항목을 그리드에 맞추기",
		"es": "Ajustar selección a la cuadrícula", "pt": "Alinhar seleção à grade", "ru": "Выровнять выделение по сетке",
	},
	"GRID_SIZE_TOOLTIP": {
		"zh": "栅格尺寸（[ 和 ] 切换）", "en": "Grid size ([ and ] to change)", "ja": "グリッドサイズ（[ と ] で変更）", "ko": "그리드 크기 ([ 및 ]로 변경)",
		"es": "Tamaño de cuadrícula ([ y ] para cambiar)", "pt": "Tamanho da grade ([ e ] para mudar)", "ru": "Шаг сетки ([ и ] для изменения)",
	},
	"SNAP": {
		"zh": "吸附", "en": "Snap", "ja": "スナップ", "ko": "스냅",
		"es": "Ajuste", "pt": "Encaixe", "ru": "Привязка",
	},
	"SNAP_TOOLTIP": {
		"zh": "CSG Blockout 工具按栅格吸附（拖动时按住 Ctrl 临时反转）", "en": "Snap CSG Blockout tools to the grid (hold Ctrl while dragging to invert)",
		"ja": "CSG Blockout のツールをグリッドにスナップ（ドラッグ中 Ctrl で一時反転）", "ko": "CSG Blockout 도구를 그리드에 스냅 (드래그 중 Ctrl로 일시 반전)",
		"es": "Ajustar las herramientas de CSG Blockout a la cuadrícula (mantén Ctrl al arrastrar para invertir)", "pt": "Encaixar as ferramentas do CSG Blockout na grade (segure Ctrl ao arrastar para inverter)",
		"ru": "Привязка инструментов CSG Blockout к сетке (удерживайте Ctrl при перетаскивании, чтобы инвертировать)",
	},
	"MORE_ACTIONS_TOOLTIP": {
		"zh": "更多 CSG Blockout 操作", "en": "More CSG Blockout actions", "ja": "その他の CSG Blockout 操作", "ko": "기타 CSG Blockout 작업",
		"es": "Más acciones de CSG Blockout", "pt": "Mais ações do CSG Blockout", "ru": "Другие действия CSG Blockout",
	},
}
