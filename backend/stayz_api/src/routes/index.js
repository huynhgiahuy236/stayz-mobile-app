const router = require('express').Router();

router.use('/auth', require('./auth.routes'));
router.use('/users', require('./user.routes'));
router.use('/hotels', require('./hotel.routes'));
router.use('/rooms', require('./room.routes'));
router.use('/bookings', require('./booking.routes'));
router.use('/payments', require('./payment.routes'));
router.use('/favorites', require('./favorite.routes'));
router.use('/reviews', require('./review.routes'));
router.use('/notifications', require('./notification.routes'));

module.exports = router;
