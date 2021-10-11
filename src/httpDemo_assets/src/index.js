import { httpDemo } from "../../declarations/httpDemo";

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  // Interact with httpDemo actor, calling the greet method
  const greeting = await httpDemo.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
