const express = require("express");
const propertiesController = require("../controllers/properties.controller");
const uploadLocalMiddleware = require("../middlewares/uploadLocal.middleware");
const uploadCloud = require("../middlewares/uploadCloud.middleware");
const protect = require("../middlewares/protect.middleware");
const propertiesRouter = express.Router();

// Search routes — phải đặt TRƯỚC /:city để không bị match nhầm
propertiesRouter.get("/search", propertiesController.search);
propertiesRouter.get("/search/history", protect, propertiesController.getSearchHistory);
propertiesRouter.delete("/search/history", protect, propertiesController.clearSearchHistory);
propertiesRouter.get("/featured", propertiesController.getFeatured);

propertiesRouter.get("/getAll", propertiesController.getAll);
propertiesRouter.get("/:city", propertiesController.getCity);
propertiesRouter.get("/:city/:slug", propertiesController.getBySlug);
propertiesRouter.post("/create", propertiesController.create);
propertiesRouter.put("/update/:id", propertiesController.update);
propertiesRouter.delete("/delete/:id", propertiesController.delete);
propertiesRouter.patch(
  "/upload/local/:id",
  uploadLocalMiddleware.single("image"),
  propertiesController.uploadMainImageLocal,
);
propertiesRouter.patch(
  "/upload/cloud/:id",
  uploadCloud.single("image"),
  propertiesController.uploadMainImageCloud,
);
propertiesRouter.patch(
  "/upload/gallery/cloud/:id",
  uploadCloud.array("images", 10),
  propertiesController.uploadGalleryCloud,
);

module.exports = propertiesRouter;
