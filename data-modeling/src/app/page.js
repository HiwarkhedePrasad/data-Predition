"use client"; // Make sure this line is present

import { useState } from 'react';
import axios from 'axios';

export default function Home() {
    const [message, setMessage] = useState('');
    const [reply, setReply] = useState(null);
    const [error, setError] = useState(null);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null); // Reset error
        try {
            const response = await axios.post('/api/chat', { message }); 
            console.log(response);// Adjusted to '/api/chat'
            setReply(response.data.reply);
        } catch (err) {
            setError('Error communicating with ChatGPT');
        }
        
    };

    return (
        <div className="flex flex-col items-center justify-center h-screen bg-gray-100">
            <h1 className="text-3xl font-bold mb-4">Chat with GPT</h1>
            <form onSubmit={handleSubmit} className="flex flex-col items-center">
                <input
                    type="text"
                    value={message}
                    onChange={(e) => setMessage(e.target.value)}
                    placeholder="Type your message"
                    required
                    className="mb-2 p-2 border border-gray-300 rounded w-64"
                />
                <button
                    type="submit"
                    className="bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition duration-300"
                >
                    Send
                </button>
            </form>
            {reply && <div className="mt-4 text-xl">GPT: {reply}</div>}
            {error && <div className="mt-4 text-red-500">{error}</div>}
        </div>
    );
}
