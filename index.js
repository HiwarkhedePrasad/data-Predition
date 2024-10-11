const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { spawn } = require('child_process');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Route to handle predictions
app.post('/predict', (req, res) => {
    const params = req.body;

    // Call R script with parameters
    const rScript = spawn('Rscript', ['path/to/your_script.R', JSON.stringify(params)]);

    rScript.stdout.on('data', (data) => {
        res.json({ prediction: data.toString() });
    });

    rScript.stderr.on('data', (data) => {
        console.error(`stderr: ${data}`);
        res.status(500).json({ error: 'Error processing request' });
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
