# MDPro3 DIY 写卡工作准则

本工作区当前目标路径是：

```text
D:\Game\MDPro3
```

此前文档中出现的 `D:\YGOMD\MDPro3`、`D:\YGOMD\MDPro3_Work` 等路径视为旧路径；除非用户明确要求回旧安装调试，否则不要作为写卡或安装目标。

## 核心原则

自制卡不要改 MDPro3 的基础数据文件。使用 `Expansions` 目录放独立扩展包：

```text
D:\Game\MDPro3\Expansions\ghost-pokemon.cdb
D:\Game\MDPro3\Expansions\ghost-pokemon.conf
D:\Game\MDPro3\Expansions\script\c<ID>.lua
```

不要修改这些基础文件：

```text
D:\Game\MDPro3\Data\locales\zh-CN\cards.cdb
D:\Game\MDPro3\Data\locales\zh-CN\strings.conf
D:\Game\MDPro3\Data\cards_Lite.json
D:\Game\MDPro3\Data\script.zip
```

也不要把 DIY 卡打进 `.ypk`，除非以后找到并验证了 MDPro3 专用 `.ypk` 文档。

## 扩展包结构

一个扩展包至少包含：

```text
ghost-pokemon.cdb
ghost-pokemon.conf
script\
  c117700001.lua
  c117700002.lua
  ...
```

`ghost-pokemon.conf` 负责注册系列名，例如：

```text
# Ghost Pokemon custom cards
!setname 0x1770 幽灵宝可梦
```

当前「幽灵宝可梦」系列使用：

```text
Setcode: 0x1770
Card ID: 117700001 - 117700029
```

MDPro3 / ygopro 卡号需要保持在 `10000` 到 `0x0FFFFFFF`（十进制 `268435455`）之间。不要再使用 `910000001` 这类越界 ID；越界卡号会导致 `aux.Stringid(id,n)` 等决斗中提示文本出现空白或不稳定。

如果扩展包卡号重编号，必须同步迁移 `D:\Game\MDPro3\Deck\*.ydk` 中的旧卡号；否则卡组仍引用旧 ID，游戏会显示“未知卡片”。当前正确 ID 是 `117700001 - 117700029`。

## 卡文写法

详细卡文规范见：

```text
D:\Game\MDPro3\CARD_TEXT_STYLE_GUIDE.md
```

效果文本优先参考 Konami 官方简体中文数据库与 PSCT 的结构。项目内统一偏官方简中口吻：

- 用 `此卡`、`此卡名`，不要和 `这张卡`、`这个卡名` 混用。
- 用 `对手`、`自己`、`牌组`、`额外牌组`、`墓地`、`除外状态`、`魔法与陷阱区域`、`怪兽区域`。
- 用 `特殊召唤`、`发动`、`使用`、`将发动无效并破坏`、`将效果无效` 等官方常见词。
- 整包统一半角数字，例如 `1回合`、`1张`、`1只`；编号效果用 `①：`、`②：`。
- 区域或类别并列用 `・`，例如 `手牌・牌组`、`魔法・陷阱・怪兽的效果`。

效果文本排列顺序：

```text
素材行或召唤条件
此卡名/此卡的共通限制。
①：条件，可以发动。处理。
②：费用，以...为对象可以发动。处理。
```

额外牌组怪兽素材行放在最前，不编号：

```text
「幽灵宝可梦」怪兽2只
协调＋协调以外的怪兽1只以上
```

特殊召唤条件或召唤限制通常也放在编号效果前，不滥用 `①`：

```text
此卡不可通常召唤，仅可通过...特殊召唤。
此卡仅可以融合召唤及以下方法特殊召唤。
```

次数限制优先合并写在编号效果前：

```text
此卡名的①②效果1回合仅可各使用1次。
此卡名的①效果1回合仅可使用1次。
此卡名的①②效果1回合1次，仅可使用其中1个。
此卡名的①②效果1回合仅可各使用1次，不可在同一连锁上发动。
此卡名以①方法的特殊召唤1回合仅可进行1次，且②效果1回合仅可使用1次。
```

魔法・陷阱卡本身的发动限制写成：

```text
此卡名的卡1回合仅可发动1张。
此卡名的卡1回合仅可发动1张，此卡名的③效果1回合仅可使用1次。
```

如果是场上表侧存在的每张卡各自的软次数限制，用 `1回合1次，...可以发动。`，不要写成卡名限制。

效果句法按「条件 / 费用与对象 / 处理」拆开：

```text
①：此卡召唤・特殊召唤的情况下可以发动。从牌组将...加入手牌。
②：舍弃1张手牌，以场上的1只怪兽为对象可以发动。将该怪兽破坏。
③：在自己的主要阶段可以发动。从手牌将...特殊召唤。
```

有对象的效果必须明确写 `以...为对象可以发动`，处理时用 `该卡`、`该怪兽`、`该对象怪兽` 指回对象。没有对象的选择，写在处理部分，用 `挑选...` 或直接写 `将...全部...`。

费用写在 `可以发动` 前，例如：

```text
支付500LP，以...为对象可以发动。
舍弃1张手牌可以发动。
从墓地将此卡除外可以发动。
将自己场上的1只怪兽解放可以发动。
```

诱发效果常用：

```text
...的情况下可以发动。
...时可以发动。
...的情况下发动。
```

必发效果不要写 `可以发动`。自己・对手回合都能用的快速效果，优先写：

```text
在自己・对手回合中，...可以发动。
```

永续效果一般不写 `可以发动`：

```text
只要此卡存在于怪兽区域，...
场上的...的攻击力上升...
```

多个处理之间的连接词要谨慎：

- `然后`：前一处理成功才继续后续处理，且后续处理在时间上靠后。
- `进而` / `并且`：用于追加处理或满足条件后的附加处理，先确认现有官方卡文有没有相近写法。
- `全部`：用于不取对象的整体处理。
- `可从以下效果中选择1个发动` 后用 `●` 分项。

写无效类文本时区分：

```text
将该发动无效并破坏。
将该效果无效。
此回合，对手不可发动...
应对此效果的发动，对手不可发动魔法・陷阱・怪兽的效果。
```

常见限制句：

```text
此效果发动后，直至回合结束时为止，自己不可...
此卡发动后，直至回合结束时为止，自己不可...
以此效果特殊召唤的怪兽的效果无效化。
以此效果特殊召唤的怪兽将在结束阶段放回手牌。
```

参考来源：

- Konami 官方卡库简体中文卡文示例：`https://www.db.yugioh-card.com/yugiohdb/card_search.action?request_locale=cn`
- PSCT 条件/费用/对象/处理结构：`https://www.yugioh-card.com/en/play/psct/psct-3/`
- PSCT 对象、费用、连锁提示：`https://www.yugioh-card.com/en/play/psct/psct-4/`
- PSCT 处理连接词含义：`https://www.yugioh-card.com/en/play/psct/psct-7/`

## CDB 建库要点

`.cdb` 是 SQLite 数据库，至少需要 `datas` 和 `texts` 两张表。

`datas` 存卡片数值、类型、种族、属性等；`texts` 存卡名、描述和效果文本。写入后必须保证每张卡在两张表里都有同一个 `id`。

常用数值：

```text
不死族 Race: 0x10
DARK 暗: 0x20
FIRE 炎: 0x4
WATER 水: 0x2
```

连接怪兽：

```text
datas.level = LINK 数值
datas.def   = 连接箭头 bitmask
```

连接箭头 bitmask：

```text
↙ BL = 1
↓ B  = 2
↘ BR = 4
← L  = 8
→ R  = 32
↖ TL = 64
↑ T  = 128
↗ TR = 256
```

魔法陷阱 type 常用值：

```text
通常魔法       2
速攻魔法       65538
永续魔法       131074
装备魔法       262146
场地魔法       524290
通常陷阱       4
反击陷阱       1048580
永续陷阱       131076
```

## Lua 脚本规范

脚本文件名必须是：

```text
c<ID>.lua
```

例如：

```text
c117700001.lua
```

每个脚本的开头建议：

```lua
local s,id,o=GetID()
local SET_GHOST_POKEMON=0x1770
function s.initial_effect(c)
    -- effects here
end
```

写脚本时优先参考 MDPro3 自带的 `Data\script.zip` 里的官方脚本写法。不要只看 Lua 语法是否正确，还要确认 API 在 MDPro3 当前脚本库里真实存在。

本项目已经确认过的坑：

```text
不要用 c:IsMonster()              改用 c:IsType(TYPE_MONSTER)
不要用 c:IsSpellTrap()            改用 c:IsType(TYPE_SPELL+TYPE_TRAP)
不要用 Card.IsMonster             改用 Card.IsType + TYPE_MONSTER
不要用 Card.IsSpellTrap           改用 Card.IsType + TYPE_SPELL+TYPE_TRAP
不要用 Duel.GetTargetCards(e)      改用 Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
不要用 aux.AddEquipProcedure       改用 aux.AddEquipSpellEffect
不要用 aux.lnklimit                自己写 link summon 限制函数
不要用 Duel.CheckReleaseGroupCost  改用 Duel.CheckReleaseGroup
不要用 Duel.SelectReleaseGroupCost 改用 Duel.SelectReleaseGroup
不要用 c:HasLevel()                改用 c:IsLevelAbove(1) 等现有判断
```

脚本与卡文同步时已经踩过的坑：

```text
如果脚本有 SetCountLimit(1,id)、SetCountLimit(1,id+100) 等卡名次数限制，卡文必须写“此卡名的...效果1回合仅可使用1次”；不要漏写成普通效果，也不要把硬次数写成每张卡各自的软 1回合1次。
同一张卡多个效果需要独立次数限制时，优先使用清晰稳定的编号，例如 id+100、id+200；遇到“第一回合能用，后续回合不刷新”的问题，先检查 SetCountLimit 的 code，不要先改卡文。
不要盲目批量替换所有 id+o；先确认该效果是否真的需要独立 code，以及当前 MDPro3 脚本环境里的行为。
如果卡的发动本身用了 id+EFFECT_COUNT_CODE_OATH，卡文应写“此卡名的卡1回合仅可发动1张”。
脚本用 Duel.SelectTarget 取对象时，卡文要写“以...为对象可以发动”；如果是在 operation 里用 Duel.SelectMatchingCard 等选择，则写处理阶段“挑选/选...”而不是写成取对象。
脚本过滤 IsFaceup() 时，卡文要写“表侧表示”；触发条件检查 rc:IsLocation(LOCATION_MZONE) 等场上来源时，卡文也要写清“自己场上的...”。
脚本 SetCost 里的动作才写在“可以发动”前作为费用；如果解放、送墓、除外等动作发生在 operation 里，就不要写成费用，改写为“可以发动。将...解放/送去墓地/除外，...”。
改完 ghost-pokemon.cdb 或脚本后，要重新打包，并验证压缩包内容确实来自当前 Expansions；同时对 CDB 跑 pragma integrity_check，避免把旧文件发给别人测试。
```

快速效果时点相关坑：

```text
MDPro3 中仅写 EFFECT_TYPE_QUICK_O + EVENT_FREE_CHAIN 的效果，可能在对手回合无法响应对手的效果发动而弹出连锁提示。
卡文写“在自己・对手回合中可以发动”的自由快速效果，若设计目标是“自己回合自由发动、对手回合连锁对手发动”，优先拆成两个注册效果：自己回合用 EVENT_FREE_CHAIN，对手回合克隆一份 EVENT_CHAINING。
两份效果必须共用同一个 SetCountLimit code，例如都用 SetCountLimit(1,id+100)，否则同一效果会变成各自可用1次。
对手回合的 EVENT_CHAINING 条件建议显式写 Duel.GetTurnPlayer()==1-tp and rp==1-tp；如果限定主要阶段，再加 Duel.IsMainPhase()。
如果原效果已有条件，例如 aux.exccon 或“对手主要阶段”，新条件要合并原条件，不要覆盖丢失。
本次已按此经验处理 c117700001、c117700002、c117700006、c117700007、c117700010、c117700013、c117700014、c117700017、c117700019、c117700026、c117700028、c117700029。
```

融合素材相关脚本坑：

```text
EFFECT_EXTRA_FUSION_MATERIAL 的 SetValue 在 MDPro3 里优先按官方脚本写成 function(e,c) 或直接 SetValue(1)，不要照搬其他分支的 function(chk,summon_type,e,...) 写法。
如果额外牌组的融合怪兽自身提供“自己墓地怪兽也可除外作为融合素材”的效果，参考 Data\script.zip 里的 c72064891.lua、c2344618.lua、c5370235.lua、c86758746.lua：需要补 aux.fus_mat_hack_check 保护的 Duel.GetFusionMaterial / Duel.SendtoGrave workaround。
这个 workaround 的作用是让带 EFFECT_EXTRA_FUSION_MATERIAL 的额外牌组卡能被融合手续看见，并把被选中的墓地融合素材从送墓改为除外。
类似「幽灵宝可梦－谜拟丘」这种写法仍然需要融合魔法或能进行融合召唤的效果；额外墓地素材文本不等于接触融合或直接从额外牌组特殊召唤。
```

仅 `luac -p` 通过不代表决斗里不会报错；它只能证明语法没错，不能证明 MDPro3 有这个函数。

## 推荐工作目录

可以直接以当前工作区为准，但做大改或重打包时推荐先用 staging 目录，避免一边写一边覆盖正在运行的游戏文件：

```text
D:\Game\MDPro3_Work\install_stage\
  ghost-pokemon.cdb
  ghost-pokemon.conf
  script\
    c117700001.lua
    ...
```

确认没问题后再复制到：

```text
D:\Game\MDPro3\Expansions\
```

## 验证命令

Lua 语法检查：

```powershell
luac -p (Get-ChildItem -LiteralPath 'D:\Game\MDPro3\Expansions\script' -Filter '*.lua' | ForEach-Object { $_.FullName })
```

CDB 完整性和数量检查：

```powershell
@'
import sqlite3, pathlib
p = pathlib.Path(r'D:\Game\MDPro3\Expansions\ghost-pokemon.cdb')
con = sqlite3.connect(p)
cur = con.cursor()
print('integrity:', cur.execute('pragma integrity_check').fetchone()[0])
print('datas:', cur.execute('select count(*) from datas').fetchone()[0])
print('texts:', cur.execute('select count(*) from texts').fetchone()[0])
ids = {r[0] for r in cur.execute('select id from datas')}
missing = [i for i in range(117700001, 117700030) if i not in ids]
print('missing:', missing)
con.close()
'@ | python -
```

查找 MDPro3 可能不支持的 API：

```powershell
rg -uu -n "Card\.IsMonster|Card\.IsSpellTrap|:IsMonster\(|:IsSpellTrap\(|HasLevel|aux\.lnklimit|CheckReleaseGroupCost|SelectReleaseGroupCost|GetTargetCards|AddEquipProcedure" 'D:\Game\MDPro3\Expansions\script'
```

确认背景设置，避免随机背景黑屏：

```powershell
Select-String -LiteralPath 'D:\Game\MDPro3\Data\config.conf' -Pattern '^Background->'
```

应保持：

```text
Background->1
```

`Background->0` 曾经触发随机背景 / AssetBundle 加载黑屏问题。这个黑屏不一定是写卡脚本导致的。

## 安装流程

安装或覆盖扩展前必须关闭 MDPro3。不要在游戏运行时覆盖 `Expansions`。

确认进程：

```powershell
Get-Process -Name MDPro3,UnityCrashHandler64 -ErrorAction SilentlyContinue | Select-Object ProcessName,Id,Path
```

如果没有输出，说明可以安装。

安装前先备份现有扩展：

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backup = "D:\Game\MDPro3_Backups\Expansions-$stamp"
New-Item -ItemType Directory -Path $backup -Force | Out-Null
Copy-Item -LiteralPath 'D:\Game\MDPro3\Expansions\*' -Destination $backup -Recurse -Force
```

复制 staging 到游戏目录：

```powershell
Copy-Item -LiteralPath 'D:\Game\MDPro3_Work\install_stage\ghost-pokemon.cdb' -Destination 'D:\Game\MDPro3\Expansions\ghost-pokemon.cdb' -Force
Copy-Item -LiteralPath 'D:\Game\MDPro3_Work\install_stage\ghost-pokemon.conf' -Destination 'D:\Game\MDPro3\Expansions\ghost-pokemon.conf' -Force
New-Item -ItemType Directory -Path 'D:\Game\MDPro3\Expansions\script' -Force | Out-Null
Copy-Item -LiteralPath 'D:\Game\MDPro3_Work\install_stage\script\*.lua' -Destination 'D:\Game\MDPro3\Expansions\script' -Force
```

安装后再对已安装文件跑一次 Lua/CDB 检查。

## 游戏内测试顺序

启动 MDPro3 后先不要直接判定 DIY 卡坏了，按这个顺序看：

1. 先搜普通官方卡，例如 `青眼白龙`。
2. 能搜到普通卡后，再搜 `幽灵宝可梦`。
3. 再按 ID 搜，例如 `117700001`。
4. 能看到卡后再进决斗测试效果。

如果普通卡也搜不到，大概率是游戏状态、路径、数据库加载或安装问题，不要先改脚本。

如果进游戏黑屏，先检查：

```text
D:\Game\MDPro3\Data\config.conf
Background->1
```

## 打包到另一台电脑

压缩包根目录应该直接包含：

```text
ghost-pokemon.cdb
ghost-pokemon.conf
script\
```

打包命令：

```powershell
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$root = 'D:\Game\MDPro3\Expansions'
$zip = "D:\Game\MDPro3\ghost-pokemon-expansion-$stamp.zip"
$items = Get-ChildItem -LiteralPath $root -Force | Where-Object { $_.Name -in @('ghost-pokemon.cdb','ghost-pokemon.conf','script') }
Compress-Archive -Path ($items.FullName) -DestinationPath $zip -CompressionLevel Optimal -Force
```

验证压缩包内容：

```powershell
$zip = (Get-ChildItem -LiteralPath 'D:\Game\MDPro3' -Filter 'ghost-pokemon-expansion-*.zip' | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
try {
  'ZIP: ' + $zip
  'ENTRY_COUNT: ' + $archive.Entries.Count
  $archive.Entries | Sort-Object FullName | Select-Object FullName,Length | Format-Table -AutoSize
} finally {
  $archive.Dispose()
}
Get-FileHash -LiteralPath $zip -Algorithm SHA256
```

搬到另一台电脑后，把 zip 内容解压到那台电脑的：

```text
MDPro3\Expansions\
```

同样要在游戏关闭时覆盖。

## 回滚

只删除自制扩展文件，不要动 `Data`：

```text
D:\Game\MDPro3\Expansions\ghost-pokemon.cdb
D:\Game\MDPro3\Expansions\ghost-pokemon.conf
D:\Game\MDPro3\Expansions\script\c117700001.lua
...
D:\Game\MDPro3\Expansions\script\c117700029.lua
```

或者直接恢复安装前备份的 `Expansions` 目录。

## 当前幽灵宝可梦包状态

当前已安装扩展位置：

```text
D:\Game\MDPro3\Expansions
```

当前工作区里可见的已打包文件包括：

```text
D:\Game\MDPro3\ghost-pokemon-expansion-20260427-215010.zip
D:\Game\MDPro3\ghost-pokemon-expansion-20260427-232534.zip
```

继续改卡前，优先检查 `Expansions` 中的实际 `.cdb` 与脚本，而不是旧路径中的 staging 文件。
