import * as http from "http";
export const lambdaHandler = async (event, context) => {
  const payload = JSON.stringify({ event: event, context: context });
  const options = {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": payload.length,
    },
    hostname: process.env.TS_REMOTE_PROXY_HOST,
    port: Number(process.env.TS_REMOTE_PROXY_PORT),
    path: "/",
  };
  const proxyResponse = await new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => (body += chunk));
      res.on("end", () => resolve(JSON.parse(body)));
    });
    req.setTimeout(20000, () => {
      req.destroy();
      reject(new Error("Request timed out"));
    });
    req.write(payload);
    req.end();
  });
  return JSON.parse(proxyResponse);
};
