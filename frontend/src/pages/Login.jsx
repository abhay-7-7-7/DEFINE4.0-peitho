import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { TrendingUp, LogIn, Mail, Lock, ArrowRight, AlertCircle, Eye, EyeOff } from 'lucide-react';
import NeoButton from '../components/NeoButton';
import { loginUser, saveAuthToken, saveAuthUser } from '../lib/api';

export default function Login() {
    const navigate = useNavigate();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');

        if (!email || !password) {
            setError('Please fill in all fields');
            return;
        }

        setLoading(true);
        try {
            const data = await loginUser(email, password);
            saveAuthToken(data.token);
            saveAuthUser(data.user);
            navigate('/');
        } catch (err) {
            setError(err.message || 'Login failed. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-neo-cream flex flex-col items-center justify-center relative overflow-hidden px-4">
            {/* Background decorations */}
            <div className="absolute inset-0 opacity-20 pointer-events-none">
                <div className="absolute top-20 left-10 w-32 h-32 border-[4px] border-neo-navy rotate-12"></div>
                <div className="absolute top-40 right-20 w-24 h-24 border-[4px] border-neo-teal -rotate-6"></div>
                <div className="absolute bottom-20 left-1/4 w-16 h-16 bg-neo-orange"></div>
                <div className="absolute bottom-40 right-1/3 w-20 h-20 bg-neo-teal rotate-45"></div>
                <div className="absolute top-1/3 right-10 w-12 h-12 border-[4px] border-neo-orange rotate-45"></div>
                <div className="absolute bottom-1/4 left-16 w-28 h-28 border-[4px] border-neo-maroon -rotate-12"></div>
            </div>

            {/* Logo */}
            <div className="relative z-10 mb-8 text-center">
                <h1 className="text-6xl md:text-8xl font-heading font-bold leading-none text-neo-navy">
                    TRADE
                    <span className="block text-neo-orange relative">
                        MIND
                        <svg className="absolute -bottom-2 left-0 w-full h-4" viewBox="0 0 200 20">
                            <path d="M0 10 Q50 0, 100 10 T200 10" stroke="#FF7D00" strokeWidth="4" fill="none" />
                        </svg>
                    </span>
                </h1>
            </div>

            {/* Login Card */}
            <div className="relative z-10 w-full max-w-md neo-card p-8">
                <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 bg-neo-teal border-[3px] border-neo-navy flex items-center justify-center">
                        <LogIn className="w-5 h-5 text-neo-cream" />
                    </div>
                    <h2 className="text-2xl font-heading font-bold text-neo-navy">SIGN IN</h2>
                </div>

                {/* Error message */}
                {error && (
                    <div className="mb-4 p-3 bg-neo-maroon/10 border-[2px] border-neo-maroon flex items-center gap-2">
                        <AlertCircle className="w-4 h-4 text-neo-maroon flex-shrink-0" />
                        <span className="text-sm font-body text-neo-maroon">{error}</span>
                    </div>
                )}

                <form onSubmit={handleSubmit} className="space-y-5">
                    {/* Email */}
                    <div>
                        <label className="block text-xs font-heading font-bold text-neo-navy/60 uppercase tracking-widest mb-2">
                            Email
                        </label>
                        <div className="flex items-center border-[3px] border-neo-navy overflow-hidden">
                            <span className="px-3 py-3 bg-neo-navy text-neo-cream">
                                <Mail className="w-5 h-5" />
                            </span>
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="Enter your email"
                                className="flex-1 px-4 py-3 bg-neo-cream text-neo-navy font-body placeholder:text-neo-navy/40 focus:outline-none focus:bg-white transition-colors"
                                disabled={loading}
                            />
                        </div>
                    </div>

                    {/* Password */}
                    <div>
                        <label className="block text-xs font-heading font-bold text-neo-navy/60 uppercase tracking-widest mb-2">
                            Password
                        </label>
                        <div className="flex items-center border-[3px] border-neo-navy overflow-hidden">
                            <span className="px-3 py-3 bg-neo-navy text-neo-cream">
                                <Lock className="w-5 h-5" />
                            </span>
                            <input
                                type={showPassword ? 'text' : 'password'}
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="Enter your password"
                                className="flex-1 px-4 py-3 bg-neo-cream text-neo-navy font-body placeholder:text-neo-navy/40 focus:outline-none focus:bg-white transition-colors"
                                disabled={loading}
                            />
                            <button
                                type="button"
                                onClick={() => setShowPassword(!showPassword)}
                                className="px-3 py-3 bg-neo-cream text-neo-navy/60 hover:text-neo-navy transition-colors"
                            >
                                {showPassword ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
                            </button>
                        </div>
                    </div>

                    {/* Submit Button */}
                    <NeoButton
                        type="submit"
                        variant="orange"
                        size="lg"
                        className="w-full mt-2"
                        disabled={loading}
                    >
                        <span className="flex items-center justify-center gap-2">
                            {loading ? 'Signing in...' : 'Sign In'}
                            {!loading && <ArrowRight className="w-5 h-5" />}
                        </span>
                    </NeoButton>
                </form>

                {/* Register link */}
                <div className="mt-6 text-center">
                    <p className="text-sm text-neo-navy/60 font-body">
                        Don't have an account?{' '}
                        <Link to="/register" className="font-bold text-neo-teal hover:text-neo-orange transition-colors underline underline-offset-2">
                            Create one
                        </Link>
                    </p>
                </div>
            </div>

            {/* Bottom tag */}
            <div className="relative z-10 mt-6">
                <span className="neo-badge-navy text-xs">
                    <TrendingUp className="w-3 h-3" />
                    NEGOTIATION AI ENGINE v1.0
                </span>
            </div>
        </div>
    );
}
