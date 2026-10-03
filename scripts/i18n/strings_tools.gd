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
	"PUSH_FACE_ACTION": {
		"zh": "推拉面", "en": "Push/Pull Face", "ja": "面を押し出し/引き込み", "ko": "면 밀기/당기기",
		"es": "Empujar/tirar cara", "pt": "Empurrar/puxar face", "ru": "Сдвинуть грань",
	},
	"ARRAY_ACTION": {
		"zh": "沿轴复制", "en": "Duplicate Along Axis", "ja": "軸に沿って複製", "ko": "축을 따라 복제",
		"es": "Duplicar a lo largo de un eje", "pt": "Duplicar ao longo do eixo", "ru": "Дублировать вдоль оси",
	},
	"ARRAY_LABEL": {
		"zh": "×%d · 间距 %s m · 轴 %s", "en": "×%d · step %s m · axis %s", "ja": "×%d · 間隔 %s m · 軸 %s", "ko": "×%d · 간격 %s m · 축 %s",
		"es": "×%d · paso %s m · eje %s", "pt": "×%d · passo %s m · eixo %s", "ru": "×%d · шаг %s м · ось %s",
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
	"MORE_MENU": {
		"zh": "更多", "en": "More", "ja": "その他", "ko": "더 보기",
		"es": "Más", "pt": "Mais", "ru": "Ещё",
	},
	"MORE_ACTIONS_TOOLTIP": {
		"zh": "更多 CSG Blockout 操作", "en": "More CSG Blockout actions", "ja": "その他の CSG Blockout 操作", "ko": "기타 CSG Blockout 작업",
		"es": "Más acciones de CSG Blockout", "pt": "Mais ações do CSG Blockout", "ru": "Другие действия CSG Blockout",
	},
	"TOOL_BOX": {
		"zh": "方块", "en": "Box", "ja": "ボックス", "ko": "박스",
		"es": "Caja", "pt": "Caixa", "ru": "Блок",
	},
	"TOOL_ROOM": {
		"zh": "房间", "en": "Room", "ja": "部屋", "ko": "방",
		"es": "Habitación", "pt": "Sala", "ru": "Комната",
	},
	"TOOL_CUT": {
		"zh": "切割", "en": "Cut", "ja": "切り抜き", "ko": "자르기",
		"es": "Cortar", "pt": "Cortar", "ru": "Вырез",
	},
	"DRAW_BOX_TOOLTIP": {
		"zh": "方块：在表面或地面上拖出底面，松开即完成（双击按钮可连续使用）", "en": "Box: drag out a base on a surface or the ground and release (double-click to keep the tool on)", "ja": "ボックス：面か地面で底面をドラッグして離すだけ（ダブルクリックで連続使用）", "ko": "박스: 표면이나 바닥에서 밑면을 드래그하고 놓기 (더블 클릭하면 계속 사용)",
		"es": "Caja: arrastra una base sobre una superficie o el suelo y suelta (doble clic para mantener la herramienta)", "pt": "Caixa: arraste uma base sobre uma superfície ou o chão e solte (clique duplo para manter a ferramenta)", "ru": "Блок: протяните основание по поверхности или земле и отпустите (двойной щелчок — оставить инструмент)",
	},
	"DRAW_ROOM_TOOLTIP": {
		"zh": "房间：拖出地面，松开即生成一个独立的空心房间；层高、墙厚等见项目设置 addons/csg_blockout/room（双击按钮可连续使用）", "en": "Room: drag out the floor and release to make a hollow room of its own; height, wall thickness and more in Project Settings > addons/csg_blockout/room (double-click to keep the tool on)", "ja": "部屋：床をドラッグして離すと独立した中空の部屋に。高さや壁厚はプロジェクト設定 addons/csg_blockout/room（ダブルクリックで連続使用）", "ko": "방: 바닥을 드래그하고 놓으면 독립된 빈 방이 생깁니다. 높이·벽 두께는 프로젝트 설정 addons/csg_blockout/room (더블 클릭하면 계속 사용)",
		"es": "Habitación: arrastra el suelo y suelta para crear una habitación hueca propia; altura, grosor de muros y más en Ajustes del proyecto > addons/csg_blockout/room (doble clic para mantener la herramienta)", "pt": "Sala: arraste o piso e solte para criar uma sala oca própria; altura, espessura das paredes e mais em Configurações do projeto > addons/csg_blockout/room (clique duplo para manter a ferramenta)", "ru": "Комната: протяните пол и отпустите — получится отдельная полая комната; высота, толщина стен и прочее в настройках проекта addons/csg_blockout/room (двойной щелчок — оставить инструмент)",
	},
	"DRAW_CUT_TOOLTIP": {
		"zh": "切割：在物体表面拖出切口，松开即贯穿切开（双击按钮可连续使用）", "en": "Cut: drag out an opening on an object's surface and release to cut through it (double-click to keep the tool on)", "ja": "切り抜き：オブジェクトの面で開口をドラッグして離すと貫通して切り抜く（ダブルクリックで連続使用）", "ko": "자르기: 물체 표면에서 구멍을 드래그하고 놓으면 관통해서 잘라냅니다 (더블 클릭하면 계속 사용)",
		"es": "Cortar: arrastra una abertura sobre la superficie de un objeto y suelta para atravesarlo (doble clic para mantener la herramienta)", "pt": "Cortar: arraste uma abertura na superfície de um objeto e solte para atravessá-lo (clique duplo para manter a ferramenta)", "ru": "Вырез: протяните проём по поверхности объекта и отпустите, чтобы прорезать его насквозь (двойной щелчок — оставить инструмент)",
	},
	"OPENING_DOOR_TOOLTIP": {
		"zh": "门：点击墙面开出门洞，自动落地、按墙厚切穿（双击按钮可连续使用）", "en": "Door: click a wall to cut a doorway, dropped to the floor and cut through the wall (double-click to keep the tool on)", "ja": "ドア：壁をクリックして床まで壁厚を貫通する開口を切る（ダブルクリックで連続使用）", "ko": "문: 벽을 클릭해 바닥까지 벽을 관통하는 문 구멍을 뚫기 (더블 클릭하면 계속 사용)",
		"es": "Puerta: haz clic en un muro para abrir un hueco a ras de suelo que lo atraviesa (doble clic para mantener la herramienta)", "pt": "Porta: clique numa parede para abrir um vão no nível do chão que a atravessa (clique duplo para manter a ferramenta)", "ru": "Дверь: щёлкните по стене, чтобы вырезать проём от пола насквозь (двойной щелчок — оставить инструмент)",
	},
	"OPENING_WINDOW_TOOLTIP": {
		"zh": "窗：点击墙面按窗台高度开出窗洞（双击按钮可连续使用）", "en": "Window: click a wall to cut a window at sill height (double-click to keep the tool on)", "ja": "窓：壁をクリックして窓台の高さに開口を切る（ダブルクリックで連続使用）", "ko": "창문: 벽을 클릭해 창턱 높이에 창 구멍 뚫기 (더블 클릭하면 계속 사용)",
		"es": "Ventana: haz clic en un muro para abrir una ventana a la altura del alféizar (doble clic para mantener la herramienta)", "pt": "Janela: clique numa parede para abrir uma janela na altura do peitoril (clique duplo para manter a ferramenta)", "ru": "Окно: щёлкните по стене, чтобы вырезать окно на высоте подоконника (двойной щелчок — оставить инструмент)",
	},
	"STEP_DRAW_BOX": {
		"zh": "在表面上拖出底面", "en": "Drag out the base on a surface", "ja": "面の上で底面をドラッグ", "ko": "표면 위에서 밑면을 드래그",
		"es": "Arrastra la base sobre una superficie", "pt": "Arraste a base sobre uma superfície", "ru": "Протяните основание по поверхности",
	},
	"STEP_DRAW_ROOM": {
		"zh": "拖出房间的地面", "en": "Drag out the room's floor", "ja": "部屋の床をドラッグ", "ko": "방의 바닥을 드래그",
		"es": "Arrastra el suelo de la habitación", "pt": "Arraste o piso da sala", "ru": "Протяните пол комнаты",
	},
	"STEP_DRAW_CUT": {
		"zh": "在物体表面上拖出切口", "en": "Drag out the cut on a surface", "ja": "面の上で切り抜きをドラッグ", "ko": "표면 위에서 잘라낼 영역을 드래그",
		"es": "Arrastra el corte sobre una superficie", "pt": "Arraste o corte sobre uma superfície", "ru": "Протяните вырез по поверхности",
	},
	"STEP_RELEASE": {
		"zh": "松开即完成", "en": "Release to finish", "ja": "離すと完成", "ko": "놓으면 완성",
		"es": "Suelta para terminar", "pt": "Solte para concluir", "ru": "Отпустите, чтобы закончить",
	},
	"STEP_CUT_NEEDS_SURFACE": {
		"zh": "切口要从物体表面开始拖", "en": "Start the cut on an object's surface", "ja": "切り抜きはオブジェクトの面から始めてください", "ko": "자르기는 물체 표면에서 시작하세요",
		"es": "Empieza el corte sobre la superficie de un objeto", "pt": "Comece o corte na superfície de um objeto", "ru": "Начните вырез на поверхности объекта",
	},
	"STEP_OPENING_HOVER": {
		"zh": "移到墙面上", "en": "Move onto a wall", "ja": "壁の上へ", "ko": "벽 위로 이동",
		"es": "Pasa sobre un muro", "pt": "Passe sobre uma parede", "ru": "Наведите на стену",
	},
	"STEP_DOOR_CLICK": {
		"zh": "点击开门", "en": "Click to cut the door", "ja": "クリックでドアを開ける", "ko": "클릭해서 문 뚫기",
		"es": "Haz clic para abrir la puerta", "pt": "Clique para abrir a porta", "ru": "Щёлкните, чтобы вырезать дверь",
	},
	"STEP_WINDOW_CLICK": {
		"zh": "点击开窗", "en": "Click to cut the window", "ja": "クリックで窓を開ける", "ko": "클릭해서 창문 뚫기",
		"es": "Haz clic para abrir la ventana", "pt": "Clique para abrir a janela", "ru": "Щёлкните, чтобы вырезать окно",
	},
	"STEP_ARRAY_AXIS": {
		"zh": "沿 X、Y 或 Z 移动鼠标", "en": "Move the mouse along X, Y or Z", "ja": "X・Y・Z に沿ってマウスを動かす", "ko": "X, Y, Z 방향으로 마우스 이동",
		"es": "Mueve el ratón a lo largo de X, Y o Z", "pt": "Mova o mouse ao longo de X, Y ou Z", "ru": "Ведите мышь вдоль X, Y или Z",
	},
	"STEP_ARRAY_CLICK": {
		"zh": "点击生成 %d 份", "en": "Click to make %d copies", "ja": "クリックで %d 個作成", "ko": "클릭해서 %d개 만들기",
		"es": "Haz clic para crear %d copias", "pt": "Clique para criar %d cópias", "ru": "Щёлкните, чтобы создать копий: %d",
	},
	"TAG_SEPARATE": {
		"zh": "单独放置", "en": "Separate", "ja": "単独で配置", "ko": "따로 배치",
		"es": "Aparte", "pt": "Separado", "ru": "Отдельно",
	},
	"TAG_LOCK_AXIS": {
		"zh": "锁轴", "en": "Lock axis", "ja": "軸固定", "ko": "축 고정",
		"es": "Fijar eje", "pt": "Travar eixo", "ru": "Ось",
	},
	"TAG_GAP": {
		"zh": "间距 %s m", "en": "Gap %s m", "ja": "間隔 %s m", "ko": "간격 %s m",
		"es": "Separación %s m", "pt": "Espaço %s m", "ru": "Зазор %s м",
	},
	"TAG_LOCKED": {
		"zh": "连续使用", "en": "Repeat", "ja": "連続", "ko": "연속",
		"es": "Repetir", "pt": "Repetir", "ru": "Повтор",
	},
	"KEY_EXIT": {
		"zh": "退出", "en": "Exit", "ja": "終了", "ko": "종료",
		"es": "Salir", "pt": "Sair", "ru": "Выход",
	},
	"RESIZE_ACTION": {
		"zh": "调整尺寸", "en": "Resize", "ja": "サイズを変更", "ko": "크기 조정",
		"es": "Cambiar tamaño", "pt": "Redimensionar", "ru": "Изменить размер",
	},
	"STATUS_TREE_SELECTED": {
		"zh": "已选中整棵树：%s", "en": "Selected the whole tree: %s", "ja": "ツリー全体を選択：%s", "ko": "트리 전체 선택: %s",
		"es": "Árbol completo seleccionado: %s", "pt": "Árvore inteira selecionada: %s", "ru": "Выбрано всё дерево: %s",
	},
	"PIE_PLAY": {
		"zh": "试玩", "en": "Play", "ja": "プレイ", "ko": "플레이",
		"es": "Jugar", "pt": "Jogar", "ru": "Играть",
	},
	"PIE_SHAPES": {
		"zh": "形状", "en": "Shapes", "ja": "形状", "ko": "도형",
		"es": "Formas", "pt": "Formas", "ru": "Фигуры",
	},
	"PIE_SNAP": {
		"zh": "对齐栅格", "en": "Snap to Grid", "ja": "グリッドに揃える", "ko": "그리드에 맞추기",
		"es": "Ajustar a la cuadrícula", "pt": "Alinhar à grade", "ru": "По сетке",
	},
	"PIE_TO_UNION": {
		"zh": "改为并集", "en": "Make Union", "ja": "和集合にする", "ko": "합집합으로",
		"es": "Convertir en unión", "pt": "Tornar união", "ru": "Сделать объединением",
	},
	"PIE_TO_SUBTRACT": {
		"zh": "改为差集", "en": "Make Subtraction", "ja": "差集合にする", "ko": "차집합으로",
		"es": "Convertir en sustracción", "pt": "Tornar subtração", "ru": "Сделать вычитанием",
	},
	"PIE_TO_INTERSECT": {
		"zh": "改为交集", "en": "Make Intersection", "ja": "積集合にする", "ko": "교집합으로",
		"es": "Convertir en intersección", "pt": "Tornar interseção", "ru": "Сделать пересечением",
	},
	"REASON_SELECT_CSG": {
		"zh": "先选中 CSG 物体", "en": "Select a CSG shape first", "ja": "先に CSG を選択してください", "ko": "먼저 CSG를 선택하세요",
		"es": "Selecciona primero una forma CSG", "pt": "Selecione primeiro uma forma CSG", "ru": "Сначала выберите CSG-фигуру",
	},
	"REASON_SELECT_ANY": {
		"zh": "先选中物体", "en": "Select something first", "ja": "先にオブジェクトを選択してください", "ko": "먼저 대상을 선택하세요",
		"es": "Selecciona algo primero", "pt": "Selecione algo primeiro", "ru": "Сначала выберите объект",
	},
	"STATUS_OP_CHANGED": {
		"zh": "已把 %d 个改为%s", "en": "Changed %d to %s", "ja": "%d 個を%sに変更しました", "ko": "%d개를 %s(으)로 변경했습니다",
		"es": "%d cambiados a %s", "pt": "%d alterados para %s", "ru": "Изменено: %d → %s",
	},
}
