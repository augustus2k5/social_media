const express = require("express");
const bcrypt = require("bcrypt");
const User = require("../models/User.js");
const jwt = require("jsonwebtoken");
const router = express.Router();

router.post("/register", async (req, res) => {
    console.log("REGISTER HIT");
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already exists" });
    }


    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);


    const newUser = new User({
      username,
      email,
      password: hashedPassword,
      role: "user",
      status: "active"
    });

    await newUser.save();

    res.status(201).json({
      message: "Register successful",
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email
      }
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(401).json({ message: "Email not found" });
    }

    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(401).json({ message: "Wrong password" });
    }

    if (user.status !== "active") {
      return res.status(403).json({ message: "Account inactive" });
    }

    const token = jwt.sign(
      {
        id: user._id,
        role: user.role
      },
      "SECRET_KEY",
      { expiresIn: "1d" }
    );

    res.json({
      message: "Login success",
      token,
      user: {
        id: user._id,
        role: user.role,
        name: user.name
      }
    });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;