# Git 协作规则

> 全队共用,开始写代码前先看一遍。
> 仓库:<https://github.com/teverer/worldcup-site>
> 定稿日期:2026-10-18 | 维护人:队长

---

## 一、分支模型

| 分支 | 用途 | 谁可以直接推 |
|---|---|---|
| `main` | **可演示的稳定版本**,答辩和提交以此为准 | 队长 |
| `dev` | 集成分支,所有人的代码先汇总到这里 | 队长合并 |
| `feature/xxx` | 个人开发分支,一人一条 | 各自推送 |

**分支命名**(和代码模块一一对应):

| 模块 | 分支名 |
|---|---|
| ① 框架与团队主页 | `feature/team` |
| ② 球队与球员 | `feature/player` |
| ③ 届次与比赛 | `feature/game` |
| ④ 留言与资讯 | `feature/comment` |
| 临时修复 | `fix/描述`,如 `fix/login-error` |

**三条铁律**

1. 永远不要直接在 `main` 上写代码。
2. 不要往 `main` 直接 push,所有改动先经过 `dev`。
3. 不要对 `dev` / `main` 执行 `git push --force`。

---

## 二、日常流程

### 第一次(克隆项目)

```bash
git clone https://github.com/teverer/worldcup-site.git
cd worldcup-site
php init --env=Development --overwrite=All
# 然后编辑 common/config/main-local.php,填入自己的数据库账号密码
```

### 每天开工前

```bash
git checkout dev
git pull --rebase origin dev
```

### 开始做自己的任务

```bash
git checkout dev
git checkout -b feature/image
git pull --rebase origin dev
```

> 分支名示例:`feature/game`。第一次创建后,后续继续用同一条分支即可,不用每次新建。

### 写完一块就提交

```bash
git add -A
git commit -m "feat(game): 比赛列表支持按届次筛选"
git push -u origin feature/game
```

### 合并进 dev

1. 打开 GitHub 仓库,进入自己的分支,点 **Compare & pull request**,目标是 `dev`;
2. 自己检查一遍改动(文件有没有多、有没有密码);
3. 点 **Merge pull request**。

> 小团队允许自己合并,但**合之前一定先 `git pull --rebase origin dev`**,否则会把别人的提交覆盖掉。

### 每周五

队长把 `dev` 合并到 `main`,作为本周的可演示版本。

---

## 三、提交信息规范

格式:

```
类型(范围): 说明
```

| 类型 | 用途 |
|---|---|
| `feat` | 新功能 |
| `fix` | 修 bug |
| `docs` | 只改文档 |
| `style` | 格式调整,不改逻辑 |
| `refactor` | 重构,不改功能 |
| `chore` | 配置、依赖、杂项 |

**范围**用模块名:`team` / `player` / `game` / `comment` / `common` / `docs`。

例子:

```
feat(game): 比赛列表支持按届次和阶段筛选
fix(comment): 修复同一用户重复点赞
docs(readme): 补充队友首次配置步骤
chore: 更新 .gitignore
```

要求:

- **一次提交只做一件事**。不要"改了三个模块"合成一条。
- 说明写"做了什么",不要写"修改""更新""提交"。
- 中英文都行,队友能看懂优先。

---

## 四、合并与冲突

### 合并前

```bash
git checkout dev
git pull --rebase origin dev
git checkout feature/game
git rebase dev
```

### 出现冲突

1. 打开冲突文件,搜索 `<<<<<<<`,保留正确内容,删掉标记;
2. `git add <文件>`;
3. `git rebase --continue`;
4. 冲突解决后**必须重新跑一遍页面**,确认没改坏。

### 合并后

```bash
git checkout dev
git pull --rebase origin dev
```

---

## 五、绝对不能提交的东西

| 内容 | 原因 |
|---|---|
| `common/config/main-local.php`、`params-local.php` | 含数据库密码 |
| `frontend/runtime/`、`backend/runtime/` | 运行日志 |
| `frontend/web/assets/`、`backend/web/assets/` | 自动生成的资源 |
| 大于 10MB 的单个文件 | 仓库会变慢,先问队长 |

这些已经在 `.gitignore` 里了,正常 `git add -A` 不会带进去。**提交前用 `git status` 看一眼**,发现不该出现的文件就停下来。

图片素材可以提交,统一放:

- 球队/球员/资讯图片:`frontend/web/uploads/{team,player,news,avatar}/`
- 作业文件:`data/team/`、`data/personal/`

---

## 六、提交频率

- **至少每天一次**。写完一个能跑的小功能就提交,不要攒到周末。
- 攒着提交有两个后果:一是冲突集中爆发,二是《实现文档》需要的 Git 记录会断档。
- 提交前至少确认:`php -l 文件.php` 通过、页面能打开。

---

## 七、给《实现文档》留证据

作业要求实现文档包含"Git 提交记录"。所以:

- commit message 按上面的格式写,能直接看出谁做了什么;
- 每周五截图一次 GitHub 的 **Commits** 页面(或 `git log --oneline --graph`);
- Trello 卡片移到「已完成」时,把 PR 链接贴在评论里。

这些材料最后都能直接放进实现文档,不用临时补。

---

## 八、常见问题

| 现象 | 处理 |
|---|---|
| `git push` 提示权限不足 | 让队长把你的 GitHub 用户名加为 collaborator |
| `rejected - non-fast-forward` | 先 `git pull --rebase origin dev`,再 push |
| 不小心在 main 上改了代码 | `git stash` → 切到 feature 分支 → `git stash pop` |
| 提交里出现了 `main-local.php` | 立即告诉队长,需要从历史里清除 |
| 不知道该提交什么 | `git status` 看一遍,只提交自己改的代码和文档 |
| 合并后网站报错 | 先 `git log` 找到自己的提交,回退或修复后再推 |
