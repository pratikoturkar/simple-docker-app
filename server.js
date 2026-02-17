const express = require('express');
const app = express();

const version = process.env.VERSION || "dev";

app.get("/", (req, res) => {
  res.send(`
    <h2>Blue-Green Deployment Demo</h2>
    <p>Version: ${version}</p>
  `);
});

app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

app.listen(8080, () => {
  console.log("App running on port 8080");
});