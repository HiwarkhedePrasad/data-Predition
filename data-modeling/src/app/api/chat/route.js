import { spawn } from 'child_process';
import path from 'path';

export async function POST(req) {
    const { message } = await req.json();

    // Construct the path to the R script
    const scriptPath = path.join(process.cwd(), 'src', 'app', 'r', 'chatgpt_interaction.R');

    return new Promise((resolve, reject) => {
        const rScript = spawn('Rscript', [scriptPath, message]);

        rScript.stdout.on('data', (data) => {
            resolve(new Response(JSON.stringify({ reply: data.toString() }), {
                status: 200,
                headers: { 'Content-Type': 'application/json' }
            }));
        });

        rScript.stderr.on('data', (data) => {
            console.error(`stderr: ${data}`);
            reject(new Response(JSON.stringify({ error: 'Error processing request', details: data.toString() }), {
                status: 500,
                headers: { 'Content-Type': 'application/json' }
            }));
        });
    });
}
