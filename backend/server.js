const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");

const authRoutes = require("./routes/authRoutes");
const conversationsRoutes = require("./routes/conversationsRoutes");

const app = express();

app.use(cors());
app.use(express.json());

mongoose.connect("mongodb://127.0.0.1:27017/socialMediaDB");

app.use("/api/auth", authRoutes);
app.use("/api/conversations", conversationsRoutes);

app.listen(5000, "0.0.0.0", () => {
  console.log("Server running on port 5000");
});