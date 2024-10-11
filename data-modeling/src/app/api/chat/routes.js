import { spawn } from 'child_process';

export async function POST(req) {
    const { message } = await req.json(); // Parse the incoming JSON request body

    return new Promise((resolve, reject) => {
        const rScript = spawn('Rscript', ['r/chatgpt_interaction.R', message]);

        rScript.stdout.on('data', (data) => {
            resolve(new Response(JSON.stringify({ reply: data.toString() }), {
                status: 200,
                headers: { 'Content-Type': 'application/json' }
            }));
        });

        rScript.stderr.on('data', (data) => {
            console.error(`stderr: ${data}`);
            reject(new Response(JSON.stringify({ error: 'Error processing request' }), {
                status: 500,
                headers: { 'Content-Type': 'application/json' }
            }));
        });
    });
}
