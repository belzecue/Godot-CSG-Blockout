@tool
extends RefCounted
## Strings for reversible bake (freeze / unfreeze) and the bake pipeline.

const STRINGS: Dictionary = {
	"FREEZE": {
		"zh": "冻结", "en": "Freeze", "ja": "フリーズ", "ko": "고정",
		"es": "Congelar", "pt": "Congelar", "ru": "Заморозить",
	},
	"UNFREEZE": {
		"zh": "解冻", "en": "Unfreeze", "ja": "フリーズ解除", "ko": "고정 해제",
		"es": "Descongelar", "pt": "Descongelar", "ru": "Разморозить",
	},
	"FREEZE_ACTION": {
		"zh": "冻结 CSG", "en": "Freeze CSG", "ja": "CSG をフリーズ", "ko": "CSG 고정",
		"es": "Congelar CSG", "pt": "Congelar CSG", "ru": "Заморозить CSG",
	},
	"UNFREEZE_ACTION": {
		"zh": "解冻 CSG", "en": "Unfreeze CSG", "ja": "CSG のフリーズを解除", "ko": "CSG 고정 해제",
		"es": "Descongelar CSG", "pt": "Descongelar CSG", "ru": "Разморозить CSG",
	},
	"FREEZE_TOOLTIP": {
		"zh": "冻结：把选中的 CSG 树烘焙成网格 + 碰撞，原 CSG 保存在节点里，可随时解冻",
		"en": "Freeze: bake the selected CSG trees into a mesh + collision; the CSG is kept inside the node so you can unfreeze any time",
		"ja": "フリーズ：選択した CSG ツリーをメッシュとコリジョンに焼き込む。CSG はノード内に保存され、いつでも解除できる",
		"ko": "고정: 선택한 CSG 트리를 메시 + 콜리전으로 굽기. CSG는 노드 안에 보관되어 언제든 해제 가능",
		"es": "Congelar: hornea los árboles CSG seleccionados en malla + colisión; el CSG se guarda en el nodo para descongelarlo cuando quieras",
		"pt": "Congelar: converte as árvores CSG selecionadas em malha + colisão; o CSG fica guardado no nó para descongelar quando quiser",
		"ru": "Заморозить: запечь выбранные деревья CSG в меш и коллизию; CSG хранится в узле, разморозить можно в любой момент",
	},
	"UNFREEZE_TOOLTIP": {
		"zh": "解冻：把冻结的网格还原成可编辑的 CSG，节点名和对节点的定制会在下次冻结时保留",
		"en": "Unfreeze: turn the frozen mesh back into editable CSG; the node name and your customizations come back on the next freeze",
		"ja": "フリーズ解除：焼き込んだメッシュを編集可能な CSG に戻す。ノード名とカスタマイズは次のフリーズで復元",
		"ko": "고정 해제: 고정된 메시를 편집 가능한 CSG로 되돌림. 노드 이름과 사용자 설정은 다음 고정 때 유지",
		"es": "Descongelar: vuelve a convertir la malla congelada en CSG editable; el nombre y tus ajustes del nodo se conservan al volver a congelar",
		"pt": "Descongelar: transforma a malha congelada de volta em CSG editável; o nome e seus ajustes do nó voltam no próximo congelamento",
		"ru": "Разморозить: вернуть замороженный меш в редактируемый CSG; имя узла и ваши настройки сохранятся при следующей заморозке",
	},
	"WARN_FREEZE_SCENE_ROOT": {
		"zh": "不能冻结场景根节点，请先把 CSG 放进一个子组合器", "en": "The scene root can't be frozen; put the CSG under a child combiner first",
		"ja": "シーンのルートはフリーズできません。先に CSG を子のコンバイナーに入れてください", "ko": "씬 루트는 고정할 수 없습니다. 먼저 CSG를 하위 컴바이너에 넣으세요",
		"es": "La raíz de la escena no se puede congelar; coloca el CSG dentro de un combinador hijo", "pt": "A raiz da cena não pode ser congelada; coloque o CSG num combinador filho",
		"ru": "Корень сцены нельзя заморозить; сначала поместите CSG в дочерний комбинатор",
	},
	"WARN_FREEZE_EMPTY": {
		"zh": "%s 没有可烘焙的几何体，已跳过", "en": "%s has no geometry to bake; skipped",
		"ja": "%s には焼き込むジオメトリがないためスキップしました", "ko": "%s에는 구울 지오메트리가 없어 건너뜁니다",
		"es": "%s no tiene geometría que hornear; se omite", "pt": "%s não tem geometria para converter; ignorado",
		"ru": "У %s нет геометрии для запекания; пропущено",
	},
	"WARN_FREEZE_REFERENCES": {
		"zh": "冻结 %s 后，这些 NodePath 会指向不存在的节点：%s", "en": "After freezing %s, these NodePaths point to nodes that no longer exist: %s",
		"ja": "%s をフリーズすると、次の NodePath が存在しないノードを指します：%s", "ko": "%s 고정 후 다음 NodePath는 존재하지 않는 노드를 가리킵니다: %s",
		"es": "Tras congelar %s, estos NodePath apuntan a nodos que ya no existen: %s", "pt": "Depois de congelar %s, estes NodePath apontam para nós que não existem mais: %s",
		"ru": "После заморозки %s эти NodePath указывают на несуществующие узлы: %s",
	},
	"FROZEN_PANEL_TITLE": {
		"zh": "❄ 冻结的白盒", "en": "❄ Frozen blockout", "ja": "❄ フリーズ済みブロックアウト", "ko": "❄ 고정된 블록아웃",
		"es": "❄ Blockout congelado", "pt": "❄ Blockout congelado", "ru": "❄ Замороженный блокаут",
	},
	"BAKE_COLLISION": {
		"zh": "碰撞", "en": "Collision", "ja": "コリジョン", "ko": "콜리전",
		"es": "Colisión", "pt": "Colisão", "ru": "Коллизия",
	},
	"COLLISION_AUTO": {
		"zh": "自动（沿用 CSG 的 use_collision）", "en": "Auto (follow the CSG's use_collision)", "ja": "自動（CSG の use_collision に従う）", "ko": "자동 (CSG의 use_collision 따름)",
		"es": "Automática (según use_collision del CSG)", "pt": "Automática (segue use_collision do CSG)", "ru": "Авто (по use_collision у CSG)",
	},
	"COLLISION_NONE": {
		"zh": "无", "en": "None", "ja": "なし", "ko": "없음",
		"es": "Ninguna", "pt": "Nenhuma", "ru": "Нет",
	},
	"COLLISION_TRIMESH": {
		"zh": "三角网格（精确）", "en": "Trimesh (exact)", "ja": "三角メッシュ（正確）", "ko": "삼각 메시 (정확)",
		"es": "Trimesh (exacta)", "pt": "Trimesh (exata)", "ru": "Тримеш (точная)",
	},
	"COLLISION_PRIMITIVES": {
		"zh": "逐图元原生形状（最快，仅纯并集）", "en": "Per-primitive shapes (fastest, union only)", "ja": "プリミティブごとの形状（最速、和のみ）", "ko": "도형별 기본 형태 (가장 빠름, 합집합만)",
		"es": "Formas por primitiva (más rápida, solo unión)", "pt": "Formas por primitiva (mais rápida, só união)", "ru": "Формы по примитивам (быстрее всего, только объединение)",
	},
	"COLLISION_CONVEX": {
		"zh": "整体凸包", "en": "Single convex hull", "ja": "全体の凸包", "ko": "전체 볼록 껍질",
		"es": "Envolvente convexa única", "pt": "Envoltória convexa única", "ru": "Одна выпуклая оболочка",
	},
	"BAKE_UV2": {
		"zh": "生成光照贴图 UV2", "en": "Lightmap UV2", "ja": "ライトマップ UV2", "ko": "라이트맵 UV2",
		"es": "UV2 para lightmap", "pt": "UV2 de lightmap", "ru": "UV2 для лайтмапа",
	},
	"BAKE_TEXEL": {
		"zh": "UV2 纹素尺寸", "en": "UV2 texel size", "ja": "UV2 テクセルサイズ", "ko": "UV2 텍셀 크기",
		"es": "Tamaño de texel UV2", "pt": "Tamanho do texel UV2", "ru": "Размер текселя UV2",
	},
	"BAKE_OCCLUDER": {
		"zh": "生成遮挡体", "en": "Occluder", "ja": "オクルーダー", "ko": "오클루더",
		"es": "Oclusor", "pt": "Oclusor", "ru": "Окклюдер",
	},
	"BAKE_LOD": {
		"zh": "生成 LOD", "en": "LODs", "ja": "LOD を生成", "ko": "LOD 생성",
		"es": "LOD", "pt": "LOD", "ru": "LOD",
	},
	"REBAKE": {
		"zh": "按这些选项重新烘焙", "en": "Rebake With These Options", "ja": "この設定で再ベイク", "ko": "이 설정으로 다시 굽기",
		"es": "Rehornear con estas opciones", "pt": "Refazer com estas opções", "ru": "Перезапечь с этими настройками",
	},
	"REBAKE_ACTION": {
		"zh": "重新烘焙冻结的白盒", "en": "Rebake Frozen Blockout", "ja": "フリーズ済みブロックアウトを再ベイク", "ko": "고정된 블록아웃 다시 굽기",
		"es": "Rehornear blockout congelado", "pt": "Refazer blockout congelado", "ru": "Перезапечь замороженный блокаут",
	},
	"WARN_PRIMITIVE_COLLISION_CUTS": {
		"zh": "树里有差集/交集，逐图元碰撞会堵住切出的洞，已改用三角网格碰撞", "en": "The tree has subtractions/intersections, which per-primitive collision would ignore; used trimesh collision instead",
		"ja": "ツリーに差/積があるため、プリミティブごとのコリジョンでは穴が塞がる。三角メッシュに切り替えました", "ko": "트리에 빼기/교집합이 있어 도형별 콜리전은 구멍을 막습니다. 삼각 메시 콜리전을 사용했습니다",
		"es": "El árbol tiene restas/intersecciones que la colisión por primitiva ignoraría; se usó trimesh", "pt": "A árvore tem subtrações/interseções que a colisão por primitiva ignoraria; usada trimesh",
		"ru": "В дереве есть вычитания/пересечения, которые коллизия по примитивам проигнорирует; использован тримеш",
	},
}
