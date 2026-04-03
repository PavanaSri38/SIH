export default function Spinner({ size = 40 }) {
  return (
    <div style={{ display:'flex', justifyContent:'center', padding:'2rem' }}>
      <div style={{
        width: size, height: size,
        border: `4px solid var(--lt-green)`,
        borderTop: `4px solid var(--green)`,
        borderRadius: '50%',
        animation: 'spin 0.8s linear infinite'
      }}/>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  )
}
