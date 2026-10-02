@tool
extends RefCounted
## Strings for the level-design metrics layer (dimensions, player reference,
## jump checks, validation, semantic tags).

const STRINGS: Dictionary = {
	"CSGPlayerReference3D": {
		"zh": "角色参照", "en": "Player Reference", "ja": "プレイヤー基準", "ko": "플레이어 기준",
		"es": "Referencia de jugador", "pt": "Referência do jogador", "ru": "Эталон игрока",
	},
	"DIMENSIONS": {
		"zh": "尺寸", "en": "Size", "ja": "寸法", "ko": "치수",
		"es": "Medidas", "pt": "Medidas", "ru": "Размеры",
	},
	"DIMENSIONS_TOOLTIP": {
		"zh": "在视口里标出选中图元的宽 × 高 × 深（米）", "en": "Label width × height × depth (meters) of the selected shapes in the viewport",
		"ja": "選択したシェイプの幅×高さ×奥行き（m）をビューポートに表示", "ko": "선택한 도형의 너비 × 높이 × 깊이(m)를 뷰포트에 표시",
		"es": "Muestra ancho × alto × fondo (metros) de las formas seleccionadas en el viewport", "pt": "Mostra largura × altura × profundidade (metros) das formas selecionadas na viewport",
		"ru": "Подписывать ширину × высоту × глубину (м) выбранных фигур во вьюпорте",
	},
	"PLAYER_REF_TOOLTIP": {
		"zh": "添加角色参照：胶囊体、蹲伏高度、可跳上的高度、冲刺跳跃弧线和最大坡度", "en": "Add a player reference: capsule, crouch height, jump-onto height, sprint-jump arc and max slope",
		"ja": "プレイヤー基準を追加：カプセル、しゃがみ高さ、飛び乗れる高さ、ダッシュジャンプ軌道、最大坂度", "ko": "플레이어 기준 추가: 캡슐, 웅크리기 높이, 점프로 오를 수 있는 높이, 대시 점프 궤적, 최대 경사",
		"es": "Añadir referencia de jugador: cápsula, altura agachado, altura de salto, arco de salto con carrera y pendiente máxima", "pt": "Adicionar referência do jogador: cápsula, altura agachado, altura de pulo, arco do pulo correndo e inclinação máxima",
		"ru": "Добавить эталон игрока: капсула, высота приседа, высота запрыгивания, дуга прыжка с разбега и максимальный уклон",
	},
	"CHECK_JUMP_MENU": {
		"zh": "检查两个选中物体之间能否跳过", "en": "Check Jump Between Two Selected", "ja": "選択した 2 つの間を跳べるか確認", "ko": "선택한 두 물체 사이 점프 가능 여부 확인",
		"es": "Comprobar salto entre los dos seleccionados", "pt": "Verificar pulo entre os dois selecionados", "ru": "Проверить прыжок между двумя выбранными",
	},
	"CHECK_JUMP_ACTION": {
		"zh": "跳跃检查", "en": "Jump Check", "ja": "ジャンプ確認", "ko": "점프 확인",
		"es": "Comprobación de salto", "pt": "Verificação de pulo", "ru": "Проверка прыжка",
	},
	"WARN_SELECT_TWO": {
		"zh": "请恰好选中两个物体", "en": "Select exactly two objects", "ja": "ちょうど 2 つのオブジェクトを選択してください", "ko": "물체를 정확히 두 개 선택하세요",
		"es": "Selecciona exactamente dos objetos", "pt": "Selecione exatamente dois objetos", "ru": "Выберите ровно два объекта",
	},
	"JUMP_RESULT_OK": {
		"zh": "间距 %s m，高差 %s m：跳得过去", "en": "Gap %s m, rise %s m: jumpable", "ja": "間隔 %s m、高低差 %s m：跳べる", "ko": "간격 %s m, 높이 차 %s m: 점프 가능",
		"es": "Separación %s m, desnivel %s m: se puede saltar", "pt": "Vão %s m, desnível %s m: dá para pular", "ru": "Зазор %s м, подъём %s м: допрыгнуть можно",
	},
	"JUMP_RESULT_FAIL": {
		"zh": "间距 %s m，高差 %s m：跳不过去", "en": "Gap %s m, rise %s m: not jumpable", "ja": "間隔 %s m、高低差 %s m：跳べない", "ko": "간격 %s m, 높이 차 %s m: 점프 불가",
		"es": "Separación %s m, desnivel %s m: no se puede saltar", "pt": "Vão %s m, desnível %s m: não dá para pular", "ru": "Зазор %s м, подъём %s м: не допрыгнуть",
	},
	"CHECKS_TAB": {
		"zh": "检查", "en": "Checks", "ja": "チェック", "ko": "검사",
		"es": "Comprobaciones", "pt": "Verificações", "ru": "Проверки",
	},
	"RUN_CHECKS": {
		"zh": "运行检查", "en": "Run Checks", "ja": "チェック実行", "ko": "검사 실행",
		"es": "Comprobar", "pt": "Verificar", "ru": "Проверить",
	},
	"CLEAR_CHECKS": {
		"zh": "清除", "en": "Clear", "ja": "クリア", "ko": "지우기",
		"es": "Limpiar", "pt": "Limpar", "ru": "Очистить",
	},
	"CHECKS_NONE": {
		"zh": "没有发现问题", "en": "No issues found", "ja": "問題は見つかりませんでした", "ko": "문제가 없습니다",
		"es": "No se encontraron problemas", "pt": "Nenhum problema encontrado", "ru": "Проблем не найдено",
	},
	"CHECKS_SUMMARY": {
		"zh": "%d 个问题", "en": "%d issues", "ja": "問題 %d 件", "ko": "문제 %d개",
		"es": "%d problemas", "pt": "%d problemas", "ru": "Проблем: %d",
	},
	"ISSUE_SLOPE": {
		"zh": "坡度 %s°，超过可行走上限 %s°", "en": "Slope %s°, steeper than the walkable %s°", "ja": "勾配 %s°、歩行可能な %s° を超えています", "ko": "경사 %s°, 걸을 수 있는 %s° 초과",
		"es": "Pendiente de %s°, más que los %s° transitables", "pt": "Inclinação de %s°, acima dos %s° caminháveis", "ru": "Уклон %s°, круче допустимых %s°",
	},
	"ISSUE_CEILING_CROUCH": {
		"zh": "天花板只有 %s m，只能蹲着通过", "en": "Ceiling only %s m: crouch only", "ja": "天井が %s m しかなく、しゃがまないと通れない", "ko": "천장이 %s m뿐이라 웅크려야 통과",
		"es": "Techo de solo %s m: solo agachado", "pt": "Teto de apenas %s m: só agachado", "ru": "Потолок всего %s м: только пригнувшись",
	},
	"ISSUE_CEILING_BLOCKED": {
		"zh": "天花板只有 %s m，蹲着也过不去", "en": "Ceiling only %s m: blocked even crouching", "ja": "天井が %s m しかなく、しゃがんでも通れない", "ko": "천장이 %s m뿐이라 웅크려도 통과 불가",
		"es": "Techo de solo %s m: bloqueado incluso agachado", "pt": "Teto de apenas %s m: bloqueado mesmo agachado", "ru": "Потолок всего %s м: не пройти даже пригнувшись",
	},
	"VALIDATE": {
		"zh": "检查", "en": "Check", "ja": "チェック", "ko": "검사",
		"es": "Comprobar", "pt": "Verificar", "ru": "Проверка",
	},
	"VALIDATE_TOOLTIP": {
		"zh": "按角色参数检查关卡：过陡的坡、过低的天花板", "en": "Check the level against the player metrics: slopes too steep, ceilings too low",
		"ja": "プレイヤー設定でレベルを確認：急すぎる坂、低すぎる天井", "ko": "플레이어 설정으로 레벨 검사: 너무 가파른 경사, 너무 낮은 천장",
		"es": "Comprueba el nivel con las métricas del jugador: pendientes demasiado inclinadas, techos demasiado bajos", "pt": "Verifica o nível com as métricas do jogador: rampas íngremes demais, tetos baixos demais",
		"ru": "Проверить уровень по параметрам игрока: слишком крутые уклоны, слишком низкие потолки",
	},
}
