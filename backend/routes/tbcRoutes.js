// routes/tbcRoutes.js
const express = require('express');
const { body } = require('express-validator');
const tbcController = require('../controllers/tbcController');
const { verifyToken } = require('../middlewares/verifyToken');

const router = express.Router();

/**
 * @route GET /api/tbc/screening
 * @desc Mendapatkan daftar pertanyaan screening TBC
 * @access Public
 */
router.get('/screening', tbcController.getScreeningQuestions);

/**
 * @route POST /api/tbc/screening
 * @desc Submit hasil screening TBC
 * @access Public
 */
router.post('/screening', [
  body('answers').isArray().withMessage('Jawaban harus dalam bentuk array'),
  body('answers.*.questionId').isInt().withMessage('ID pertanyaan harus berupa angka'),
  body('answers.*.answer').isBoolean().withMessage('Jawaban harus berupa boolean (true/false)')
], tbcController.submitScreening);

/**
 * @route GET /api/tbc/education
 * @desc Mendapatkan informasi edukasi tentang TBC
 * @access Public
 */
router.get('/education', tbcController.getTBCEducation);

module.exports = router;