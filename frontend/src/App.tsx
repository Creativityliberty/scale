import React, { useState } from 'react'

export default function App() {
  const [prompt, setPrompt] = useState('Écris un email de relance client.')
  const [agent, setAgent] = useState('writer')
  const [resp, setResp] = useState<string>('')

  async function askAgent() {
    setResp('…')
    try {
      const r = await fetch('/api/agents/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ agent, prompt })
      })
      const j = await r.json()
      setResp(typeof j.response === 'string' ? j.response : JSON.stringify(j.response, null, 2))
    } catch (e:any) {
      setResp('Erreur: ' + e.message)
    }
  }

  return (
    <div style={{ maxWidth: 860, margin: '40px auto', fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif' }}>
      <h1 style={{ marginBottom: 8 }}>Mon SaaS IA</h1>
      <p style={{ opacity: 0.8, marginTop: 0 }}>Frontend minimal React ↔ FastAPI</p>
      <div style={{ display: 'grid', gap: 12 }}>
        <label>
          Agent :
          <select value={agent} onChange={e => setAgent(e.target.value)} style={{ marginLeft: 8 }}>
            <option value="writer">writer</option>
            <option value="analyst">analyst</option>
            <option value="moderator">moderator</option>
          </select>
        </label>
        <textarea rows={6} value={prompt} onChange={e => setPrompt(e.target.value)} style={{ width: '100%' }} />
        <button onClick={askAgent} style={{ padding: '8px 16px', borderRadius: 8 }}>Poser la question</button>
        <h3>Réponse</h3>
        <pre style={{ whiteSpace: 'pre-wrap', background: '#f6f6f6', padding: 12, borderRadius: 8 }}>{resp}</pre>
      </div>
    </div>
  )
}
