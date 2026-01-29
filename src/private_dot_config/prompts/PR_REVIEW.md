# Pull Request レビュー

このブランチの作業内容をレビューしてください。

## コンテキスト

- `gh pr list --head <branch-name>` コマンドで表示される Pull Request の一覧から、該当する Pull Request を見つけてください。
- Pull Request の タイトル/説明文/コメント を確認して、変更内容の概要や PR のコンテキストを把握してください。
  - レビューコメントの取得は以下のコマンドで可能です。(JSON形式)
    - `gh api '/repos/<owner>/<repo>/pulls/<pull-request-number>/comments'`
- PR diff は以下のコマンドで取得可能です。(git diff 形式の出力)
  - `gh pr diff <pull-request-number>`

## リント

- `tools/coding_style/run.sh spell_check` コマンドを実行して、スペルミスがないか確認してください。
- `git submodule update --init --recursive && cd packages/v3_gui && make install_deps && make lint_check` コマンドを実行して、コードスタイルに問題がないか確認してください。

## レビュー項目

一般的なコードレビューの観点に加えて、以下の点を確認してください。

### typescript

- i18n

  ```typescript
  import { useTranslation } from "@/lib/react-i18next"

  const MyComponent = () => {
    const { t } = useTranslation()

    return <div>{t("key")}</div>
  }
  ```

  - `packages/v3_gui/src/types/const/translation/en.ts` にキーが過不足なく存在することを確認してください。
   - 削除されたファイルに存在するキーが残っていないことを確認してください。
  - 翻訳語句が、文脈に沿った自然な表現になっていることを確認してください。
- 不要ファイルの削除
  - 不要ファイルからしか参照されていない pages/
    - 例) 削除されたファイル内に `router.push(/page-name)` があり、他のファイルに `router.push(/page-name)` の記述がない場合、その page-name.tsx ファイルも削除してください。
  - 不要ファイルからしか参照されていない型定義、 recoilAtom, recoilKey
  - 不要ファイルの探索は芋づる式に見つかるので、繰り返し探索してください。新たに見つかる物がなくなるまで繰り返してください。
- 不要画像ファイルの削除
  - 削除されたファイルの `<Image>` コンポーネントの `src` prop で指定されている画像が、他の箇所でも使われているか確認してください。
  - 他で使用されていない画像ファイルは `packages/v3_gui/public/` から削除してください。
  - 注: Next.js では `src="/"` は `packages/v3_gui/public/` を指します。

## 結果出力

- `.ignore/reviews/<pull-request-number>_<branch_name>/<YYYYMMDD>_<sequential-number-2-digits>.md` に保存してください。
  - ブランチ名にスラッシュ (/) が含まれる場合はアンダースコア (_) に置換してください。
  - 既に同名のファイルが存在する場合は、連番をインクリメントしたファイルを作成してください。
  - 例: `.ignore/reviews/123_feature_add-auth-module/20240401_00.md`
