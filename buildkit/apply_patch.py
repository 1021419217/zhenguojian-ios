#!/usr/bin/env python3
"""真果鉴 iOS 品牌补丁：换新图标 + 把「直播」入口挪到底部导航。

在 CI 里对 actions/checkout 出来的上游源码就地打补丁：
  1) ios AppIcon 全套图标替换成新图标（不透明，无 alpha）；
  2) lib/ui/shell/app_shell.dart 增加第 5 个标签 AppTab.live（底部导航 / 侧栏 / 电视顶栏共用）；
  3) 移除首页顶栏的「直播」图标按钮与「我的」页的直播入口，避免与新标签重复。

用法: python3 apply_patch.py <源码根目录>
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else ".")
ICON_SRC = os.path.join(HERE, "ios_icons")


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def write(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def rep(rel, old, new, label):
    path = os.path.join(ROOT, rel)
    if not os.path.isfile(path):
        raise SystemExit("!! 找不到文件: " + path)
    s = read(path)
    if old not in s:
        if new and new in s:
            print("   跳过（已打过补丁）: " + label)
            return
        raise SystemExit("!! 文本锚点未命中: %s @ %s" % (label, rel))
    if s.count(old) != 1:
        raise SystemExit("!! 文本锚点不唯一（%d 处）: %s @ %s" % (s.count(old), label, rel))
    write(path, s.replace(old, new))
    print("   ok: " + label)


print("== 1. 替换 iOS 图标 ==", flush=True)
icon_dir = os.path.join(ROOT, "ios/Runner/Assets.xcassets/AppIcon.appiconset")
if not os.path.isdir(icon_dir):
    raise SystemExit("!! 没有 AppIcon.appiconset: " + icon_dir)
n = 0
for name in sorted(os.listdir(ICON_SRC)):
    if not name.endswith(".png"):
        continue
    shutil.copyfile(os.path.join(ICON_SRC, name), os.path.join(icon_dir, name))
    n += 1
print("   已写入 %d 个图标文件" % n)

print("== 2. 底部导航加入「直播」标签 ==", flush=True)
SHELL = "lib/ui/shell/app_shell.dart"
rep(
    SHELL,
    "import '../../local_store.dart';",
    "import '../../live/live_page.dart';\nimport '../../local_store.dart';",
    "import live_page",
)
rep(
    SHELL,
    "  explore('发现', Icons.explore_outlined, Icons.explore),",
    "  explore('发现', Icons.explore_outlined, Icons.explore),\n"
    "  live('直播', Icons.live_tv_outlined, Icons.live_tv_rounded),",
    "AppTab.live 枚举项",
)
rep(
    SHELL,
    "  Widget _root(AppTab tab) => switch (tab) {\n"
    "    AppTab.explore => ExplorePage(key: _explore, store: widget.store),",
    "  Widget _root(AppTab tab) => switch (tab) {\n"
    "    AppTab.explore => ExplorePage(key: _explore, store: widget.store),\n"
    "    AppTab.live => LivePage(\n"
    "      repository: sharedLiveRepository(),\n"
    "      store: liveStoreFor(widget.store),\n"
    "    ),",
    "_root 挂载 LivePage",
)
rep(
    SHELL,
    "        // 听书页与发现页一样由页面自己接管内容区焦点。\n"
    "        AppTab.explore => null,\n"
    "        AppTab.audiobook => null,",
    "        // 听书页与发现页一样由页面自己接管内容区焦点。\n"
    "        AppTab.explore => null,\n"
    "        AppTab.audiobook => null,\n"
    "        AppTab.live => null,",
    "电视顶栏方向键 switch 补分支",
)

print("== 3. 移除重复的直播入口 ==", flush=True)
EXPLORE = "lib/ui/explore/explore_page.dart"
rep(
    EXPLORE,
    "                    BarButton(\n"
    "                      icon: Icons.live_tv_rounded,\n"
    "                      tooltip: '直播',\n"
    "                      onPressed: () =>\n"
    "                          unawaited(openLive(context, store: widget.store)),\n"
    "                    ),\n",
    "",
    "首页顶栏直播按钮",
)
rep(EXPLORE, "import '../../live/live_page.dart';\n", "", "首页 live_page 导入")

MINE = "lib/ui/mine/mine_page.dart"
rep(
    MINE,
    "            children: [\n"
    "              _live(context),\n"
    "              const SizedBox(height: 10),\n"
    "              _settings(context),",
    "            children: [\n"
    "              _settings(context),",
    "我的页（手机）直播入口",
)
rep(
    MINE,
    "            const SizedBox(height: 16),\n"
    "            _live(context),\n"
    "            const SizedBox(height: 10),\n"
    "            _settings(context),",
    "            const SizedBox(height: 16),\n"
    "            _settings(context),",
    "我的页（宽屏）直播入口",
)
rep(
    MINE,
    "  /// 直播入口。与设置放在同一列，避免额外占一块版面。\n"
    "  Widget _live(BuildContext context) => _MineEntry(\n"
    "    icon: Icons.live_tv_rounded,\n"
    "    title: '直播',\n"
    "    subtitle: '卫视与直播频道',\n"
    "    onTap: () => unawaited(openLive(context, store: store)),\n"
    "  );\n\n",
    "",
    "_live() 方法",
)
rep(
    MINE,
    "                    Expanded(\n"
    "                      child: _TelevisionEntry(\n"
    "                        icon: Icons.live_tv_rounded,\n"
    "                        title: '直播',\n"
    "                        subtitle: '卫视与直播频道',\n"
    "                        onTap: () => unawaited(openLive(context, store: store)),\n"
    "                      ),\n"
    "                    ),\n",
    "",
    "我的页（电视）直播卡片",
)
rep(MINE, "import '../../live/live_page.dart';\n", "", "我的页 live_page 导入")

print("== 4. 自检 ==", flush=True)
shell = read(os.path.join(ROOT, SHELL))
assert "live('直播'" in shell and "AppTab.live => LivePage(" in shell
ex = read(os.path.join(ROOT, EXPLORE))
assert "openLive" not in ex, "首页仍残留 openLive"
mine = read(os.path.join(ROOT, MINE))
assert "openLive" not in mine, "我的页仍残留 openLive"
assert "卫视与直播频道" not in mine, "我的页仍残留直播入口文案"
for f in ("app_shell.dart", "explore_page.dart", "mine_page.dart"):
    pass
print("   全部校验通过")
print("DONE")
