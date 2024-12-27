# 編譯 (只能在Node18 這邊用Docker示範)

移動到專案根目錄

```bash
docker run -it --rm  --user 1000 -v ./:/app --workdir="/app" node:18 bash
```

進入container之後

```bash
npm install --save
npm run build
```