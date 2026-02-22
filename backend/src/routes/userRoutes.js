const express = require("express");
const {
  registerUser,
  authUser,
  allUsers,
  updateFcmToken,
} = require("../controllers/userController");
const { protect } = require("../middleware/authMiddleware");

const router = express.Router();

router.route("/").post(registerUser).get(protect, allUsers);
router.post("/login", authUser);
router.route("/fcm-token").post(protect, updateFcmToken);

module.exports = router;
