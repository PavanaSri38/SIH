import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import Landing            from './pages/Landing.jsx'
import Login              from './pages/Login.jsx'
import Register           from './pages/Register.jsx'
import Dashboard          from './pages/Dashboard.jsx'
import SoilAnalysis       from './pages/SoilAnalysis.jsx'
import CropRecommendation from './pages/CropRecommendation.jsx'
import DiseaseDetection   from './pages/DiseaseDetection.jsx'
import Weather            from './pages/Weather.jsx'
import MarketPrices       from './pages/MarketPrices.jsx'
import About              from './pages/About.jsx'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/"          element={<Landing/>}/>
        <Route path="/login"     element={<Login/>}/>
        <Route path="/register"  element={<Register/>}/>
        <Route path="/dashboard" element={<Dashboard/>}/>
        <Route path="/soil"      element={<SoilAnalysis/>}/>
        <Route path="/crop"      element={<CropRecommendation/>}/>
        <Route path="/disease"   element={<DiseaseDetection/>}/>
        <Route path="/weather"   element={<Weather/>}/>
        <Route path="/market"    element={<MarketPrices/>}/>
        <Route path="/about"     element={<About/>}/>
        <Route path="*"          element={<Navigate to="/"/>}/>
      </Routes>
    </BrowserRouter>
  )
}
