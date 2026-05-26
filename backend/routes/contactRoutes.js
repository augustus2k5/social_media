const express =
    require("express");

const router =
    express.Router();

const User =
    require("../models/User");

const verifyToken =
    require("../middleware/verifyToken");

router.get(
    "/search",

    verifyToken,

    async (req, res) => {

        try {

            const currentUserId =
                req.user.id;

            const email =
                req.query.email;

            if (!email) {

                return res
                    .status(400)
                    .json({
                        message:
                            "Email required",
                    });
            }

            const user =
                await User.findOne({

                    email: email,

                    _id: {
                        $ne: currentUserId,
                    },

                }).select(
                    "username email avatar"
                );

            if (!user) {

                return res
                    .status(404)
                    .json({
                        message:
                            "User not found",
                    });
            }

            return res
                .status(200)
                .json(user);

        } catch (err) {

            console.error(err);

            return res.status(500).json({
                message: "Server error",
            });
        }
    }
);

module.exports = router;