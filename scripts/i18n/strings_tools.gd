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
	"ROOM": {
		"zh": "房间", "en": "Room", "ja": "部屋", "ko": "방",
		"es": "Habitación", "pt": "Sala", "ru": "Комната",
	},
	"DRAW_BOX_TOOLTIP": {
		"zh": "绘制方块：在表面或地面拖出底面，再移动鼠标定高度（差集模式下即为切割）",
		"en": "Draw box: drag a base on a surface or the ground, then move the mouse to set the height (cuts in Subtraction mode)",
		"ja": "ボックスを描く：面または地面で底面をドラッグし、マウスで高さを決める（減算モードでは切り抜き）",
		"ko": "박스 그리기: 표면이나 바닥에서 밑면을 드래그한 뒤 마우스로 높이 설정 (빼기 모드에서는 잘라내기)",
		"es": "Dibujar caja: arrastra una base sobre una superficie o el suelo y mueve el ratón para fijar la altura (en modo Resta, corta)",
		"pt": "Desenhar caixa: arraste uma base numa superfície ou no chão e mova o mouse para definir a altura (no modo Subtração, corta)",
		"ru": "Нарисовать блок: протяните основание на поверхности или земле, затем мышью задайте высоту (в режиме вычитания — вырез)",
	},
	"DRAW_ROOM_TOOLTIP": {
		"zh": "绘制房间：外壳盒 + 内腔差集，墙厚与是否开顶见项目设置 addons/csg_blockout/room",
		"en": "Draw room: shell box + hollow subtraction; wall thickness and open top in Project Settings > addons/csg_blockout/room",
		"ja": "部屋を描く：外殻ボックス＋内部の減算。壁厚と天井の有無はプロジェクト設定 addons/csg_blockout/room",
		"ko": "방 그리기: 외곽 박스 + 내부 빼기. 벽 두께와 천장 개방은 프로젝트 설정 addons/csg_blockout/room",
		"es": "Dibujar habitación: caja exterior + hueco restado; grosor de muros y techo abierto en Ajustes del proyecto > addons/csg_blockout/room",
		"pt": "Desenhar sala: caixa externa + vão subtraído; espessura das paredes e teto aberto em Configurações do projeto > addons/csg_blockout/room",
		"ru": "Нарисовать комнату: внешний блок + вычитаемая полость; толщина стен и открытый верх — в настройках проекта addons/csg_blockout/room",
	},
	"HINT_DRAW_IDLE": {
		"zh": "拖动画出底面 · Esc 退出", "en": "Drag to draw the base · Esc to exit", "ja": "ドラッグで底面を描く · Esc で終了", "ko": "드래그해서 밑면 그리기 · Esc로 종료",
		"es": "Arrastra para dibujar la base · Esc para salir", "pt": "Arraste para desenhar a base · Esc para sair", "ru": "Протяните, чтобы нарисовать основание · Esc — выход",
	},
	"HINT_DRAW_BASE": {
		"zh": "松开鼠标确定底面", "en": "Release to set the base", "ja": "離して底面を確定", "ko": "놓아서 밑면 확정",
		"es": "Suelta para fijar la base", "pt": "Solte para definir a base", "ru": "Отпустите, чтобы задать основание",
	},
	"HINT_DRAW_HEIGHT": {
		"zh": "移动鼠标定高度 · 点击确认 · Esc 取消", "en": "Move to set the height · Click to confirm · Esc to cancel", "ja": "マウスで高さを決める · クリックで確定 · Esc でキャンセル", "ko": "마우스로 높이 설정 · 클릭해서 확정 · Esc로 취소",
		"es": "Mueve para fijar la altura · Clic para confirmar · Esc para cancelar", "pt": "Mova para definir a altura · Clique para confirmar · Esc para cancelar", "ru": "Двигайте мышь для высоты · Щелчок — подтвердить · Esc — отмена",
	},
	"PUSH_FACE_ACTION": {
		"zh": "推拉面", "en": "Push/Pull Face", "ja": "面を押し出し/引き込み", "ko": "면 밀기/당기기",
		"es": "Empujar/tirar cara", "pt": "Empurrar/puxar face", "ru": "Сдвинуть грань",
	},
	"DOOR": {
		"zh": "门", "en": "Door", "ja": "ドア", "ko": "문",
		"es": "Puerta", "pt": "Porta", "ru": "Дверь",
	},
	"WINDOW": {
		"zh": "窗", "en": "Window", "ja": "窓", "ko": "창문",
		"es": "Ventana", "pt": "Janela", "ru": "Окно",
	},
	"FRAME": {
		"zh": "带框", "en": "Frame", "ja": "枠あり", "ko": "틀 포함",
		"es": "Marco", "pt": "Moldura", "ru": "Рама",
	},
	"OPENING_DOOR_TOOLTIP": {
		"zh": "开门洞：点击墙面切出门洞，自动落地、按墙厚切穿", "en": "Door: click a wall to cut a doorway, dropped to the floor and cut through the wall",
		"ja": "ドア：壁をクリックして開口を切る。床に合わせ、壁厚を貫通", "ko": "문: 벽을 클릭해 문 구멍을 뚫기, 바닥에 맞추고 벽 두께만큼 관통",
		"es": "Puerta: haz clic en un muro para abrir un hueco a ras de suelo que atraviesa el muro", "pt": "Porta: clique numa parede para abrir um vão no nível do chão, atravessando a parede",
		"ru": "Дверь: щёлкните по стене, чтобы вырезать проём от пола сквозь всю толщину",
	},
	"OPENING_WINDOW_TOOLTIP": {
		"zh": "开窗洞：点击墙面按窗台高度切出窗洞", "en": "Window: click a wall to cut a window at sill height",
		"ja": "窓：壁をクリックして窓台の高さに開口を切る", "ko": "창문: 벽을 클릭해 창턱 높이에 창 구멍 뚫기",
		"es": "Ventana: haz clic en un muro para abrir una ventana a la altura del alféizar", "pt": "Janela: clique numa parede para abrir uma janela na altura do peitoril",
		"ru": "Окно: щёлкните по стене, чтобы вырезать окно на высоте подоконника",
	},
	"HINT_OPENING": {
		"zh": "点击墙面放置 · 滚轮调宽 · Shift+滚轮调高 · F 门框 · Esc 退出", "en": "Click a wall to place · Wheel: width · Shift+Wheel: height · F: frame · Esc to exit",
		"ja": "壁をクリックで配置 · ホイール：幅 · Shift+ホイール：高さ · F：枠 · Esc で終了", "ko": "벽 클릭으로 배치 · 휠: 너비 · Shift+휠: 높이 · F: 틀 · Esc로 종료",
		"es": "Clic en un muro para colocar · Rueda: ancho · Mayús+Rueda: alto · F: marco · Esc para salir", "pt": "Clique numa parede para colocar · Roda: largura · Shift+Roda: altura · F: moldura · Esc para sair",
		"ru": "Щелчок по стене — разместить · Колесо: ширина · Shift+колесо: высота · F: рама · Esc — выход",
	},
	"DRAW_MENU": {
		"zh": "绘制", "en": "Draw", "ja": "描画", "ko": "그리기",
		"es": "Dibujar", "pt": "Desenhar", "ru": "Рисовать",
	},
	"OPENINGS_MENU": {
		"zh": "开洞", "en": "Openings", "ja": "開口", "ko": "개구부",
		"es": "Huecos", "pt": "Aberturas", "ru": "Проёмы",
	},
	"MORE_MENU": {
		"zh": "更多", "en": "More", "ja": "その他", "ko": "더 보기",
		"es": "Más", "pt": "Mais", "ru": "Ещё",
	},
	"MORE_ACTIONS_TOOLTIP": {
		"zh": "更多 CSG Blockout 操作", "en": "More CSG Blockout actions", "ja": "その他の CSG Blockout 操作", "ko": "기타 CSG Blockout 작업",
		"es": "Más acciones de CSG Blockout", "pt": "Mais ações do CSG Blockout", "ru": "Другие действия CSG Blockout",
	},
}
