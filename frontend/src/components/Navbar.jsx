import { Link, useLocation, useNavigate } from 'react-router-dom';
import { LayoutDashboard, BarChart3, Settings, Code, Menu, X, Key, Mail, User, LogOut, ChevronDown, Radio, AlertTriangle, Calendar } from 'lucide-react';
import { useState, useEffect, useRef } from 'react';
import { getAuthUser, logout as apiLogout, isAuthenticated } from '../lib/api';
import logoImg from '../assets/logo.jpeg';

export default function Navbar() {
  const location = useLocation();
  const navigate = useNavigate();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const userMenuRef = useRef(null);
  const mobileUserMenuRef = useRef(null);

  const loggedIn = isAuthenticated();
  const user = getAuthUser();
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  // Close user menu on outside click
  useEffect(() => {
    const handleClickOutside = (e) => {
      const insideDesktop = userMenuRef.current && userMenuRef.current.contains(e.target);
      const insideMobile = mobileUserMenuRef.current && mobileUserMenuRef.current.contains(e.target);
      if (!insideDesktop && !insideMobile) {
        setUserMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Close menus on route change
  useEffect(() => {
    setUserMenuOpen(false);
    setMobileMenuOpen(false);
  }, [location.pathname]);

  const handleLogout = () => {
    setUserMenuOpen(false);
    setShowLogoutConfirm(true);
  };

  const confirmLogout = () => {
    apiLogout();
    setShowLogoutConfirm(false);
    navigate('/login');
  };

  const cancelLogout = () => {
    setShowLogoutConfirm(false);
  };

  const handleDropdownNavigate = (path) => {
    setUserMenuOpen(false);
    navigate(path);
  };

  const navLinks = [
    { path: '/', label: 'Home', icon: null },
    { path: '/meet-assistant', label: 'Meet Assistant', icon: Radio, highlight: true },
    { path: '/peitho/reminders', label: 'Reminders', icon: Calendar },
    { path: '/jury', label: 'Negotiate Bot', icon: LayoutDashboard },
    { path: '/products', label: 'Products', icon: LayoutDashboard },
    { path: '/authority', label: 'Analytics', icon: BarChart3 },
    { path: '/wallet', label: 'API Reference', icon: Code },
  ];

  const userMenuItems = [
    { path: '/api-access', label: 'API Access', icon: Key },
    { path: '/email-settings', label: 'Email Settings', icon: Mail },
  ];

  const userInitials = user?.full_name
    ? user.full_name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
    : user?.email
      ? user.email[0].toUpperCase()
      : 'U';

  return (
    <nav className="bg-neo-cream border-b-[3px] border-neo-navy sticky top-0 z-50">
      <div className="max-w-[1440px] mx-auto px-3 sm:px-4">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2.5 flex-shrink-0 group">
            <img
              src={logoImg}
              alt="Peitho Logo"
              className="w-9 h-9 sm:w-10 sm:h-10 object-contain rounded border-2 border-neo-navy shadow-[2px_2px_0px_#001524] transition-transform group-hover:rotate-6"
            />
            <div className="flex flex-col">
              <span className="font-heading text-xl sm:text-2xl font-black tracking-tight text-neo-navy leading-none">
                PEI<span className="text-neo-orange">THO</span>
              </span>
              <span className="text-[9px] font-mono font-bold tracking-widest text-neo-teal uppercase">
                AI NEGOTIATION
              </span>
            </div>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center gap-1.5 lg:gap-2">
            {navLinks.map((link) => {
              const isActive = location.pathname === link.path;
              const Icon = link.icon;

              return (
                <Link
                  key={link.path}
                  to={link.path}
                  className={`
                    px-2.5 lg:px-3.5 py-1.5 font-heading font-bold text-xs lg:text-sm uppercase tracking-wide
                    border-[2px] border-neo-navy transition-all duration-150
                    ${isActive
                      ? 'bg-neo-navy text-neo-cream shadow-none translate-x-[1px] translate-y-[1px]'
                      : link.highlight
                        ? 'bg-neo-orange/20 text-neo-navy hover:bg-neo-orange shadow-neo-sm hover:translate-x-[1px] hover:translate-y-[1px]'
                        : 'bg-neo-cream text-neo-navy hover:bg-neo-orange hover:translate-x-[1px] hover:translate-y-[1px] shadow-neo-sm'
                    }
                  `}
                >
                  <span className="flex items-center gap-1.5">
                    {Icon && <Icon className={`w-3.5 h-3.5 ${link.highlight ? 'text-neo-orange' : ''}`} />}
                    {link.label}
                    {link.highlight && (
                      <span className="inline-block w-2 h-2 bg-neo-orange rounded-full animate-ping" />
                    )}
                  </span>
                </Link>
              );
            })}

            {/* User Avatar / Auth Button */}
            {loggedIn ? (
              <div className="relative ml-1" ref={userMenuRef}>
                <button
                  onClick={() => setUserMenuOpen(!userMenuOpen)}
                  className={`
                    flex items-center gap-1.5 px-2 py-1.5 font-heading font-bold text-xs uppercase
                    border-[2px] border-neo-navy transition-all duration-150 shadow-neo-sm
                    ${userMenuOpen
                      ? 'bg-neo-navy text-neo-cream'
                      : 'bg-neo-cream text-neo-navy hover:bg-neo-orange/20'
                    }
                  `}
                >
                  <div className="w-7 h-7 bg-neo-orange border-[2px] border-neo-navy flex items-center justify-center">
                    <span className="text-[10px] font-black text-neo-navy">{userInitials}</span>
                  </div>
                  <ChevronDown className={`w-3.5 h-3.5 transition-transform duration-200 ${userMenuOpen ? 'rotate-180' : ''}`} />
                </button>

                {/* Dropdown */}
                {userMenuOpen && (
                  <div className="absolute right-0 mt-1 w-56 bg-neo-cream border-[3px] border-neo-navy shadow-neo z-50">
                    <div className="px-3 py-2.5 border-b-[2px] border-neo-navy/15 bg-neo-navy/5">
                      <p className="font-heading font-bold text-xs text-neo-navy truncate">
                        {user?.full_name || 'Seller'}
                      </p>
                      <p className="text-[10px] text-neo-navy/50 truncate font-mono">
                        {user?.email || ''}
                      </p>
                    </div>

                    <div className="py-1">
                      {userMenuItems.map((item) => {
                        const isActive = location.pathname === item.path;
                        const Icon = item.icon;
                        return (
                          <button
                            key={item.path}
                            onClick={() => handleDropdownNavigate(item.path)}
                            className={`
                              flex items-center gap-2.5 w-full px-3 py-2 text-xs font-bold uppercase tracking-wide
                              transition-all duration-100
                              ${isActive
                                ? 'bg-neo-navy text-neo-cream'
                                : 'text-neo-navy hover:bg-neo-orange/15 hover:pl-4'
                              }
                            `}
                          >
                            <Icon className="w-3.5 h-3.5 flex-shrink-0" />
                            {item.label}
                          </button>
                        );
                      })}
                    </div>

                    <div className="border-t-[2px] border-neo-navy/15 py-1">
                      <button
                        onClick={handleLogout}
                        className="flex items-center gap-2.5 w-full px-3 py-2 text-xs font-bold uppercase tracking-wide text-neo-maroon hover:bg-neo-maroon/10 hover:pl-4 transition-all duration-100"
                      >
                        <LogOut className="w-3.5 h-3.5 flex-shrink-0" />
                        Logout
                      </button>
                    </div>
                  </div>
                )}
              </div>
            ) : (
              <Link
                to="/login"
                className="ml-1 px-3 lg:px-4 py-1.5 font-heading font-bold text-xs lg:text-sm uppercase tracking-wide border-[2px] border-neo-navy bg-neo-orange text-neo-navy hover:translate-x-[1px] hover:translate-y-[1px] shadow-neo-sm transition-all duration-150"
              >
                <span className="flex items-center gap-1.5">
                  <User className="w-4 h-4" />
                  Login
                </span>
              </Link>
            )}
          </div>

          {/* Mobile Menu Button */}
          <div className="md:hidden flex items-center gap-2">
            {loggedIn && (
              <button
                onClick={() => setUserMenuOpen(!userMenuOpen)}
                className="p-1.5 border-[2px] border-neo-navy bg-neo-orange"
              >
                <span className="text-[10px] font-black text-neo-navy">{userInitials}</span>
              </button>
            )}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 border-[2px] border-neo-navy bg-neo-cream shadow-neo-sm"
            >
              {mobileMenuOpen ? <X className="w-5 h-5 text-neo-navy" /> : <Menu className="w-5 h-5 text-neo-navy" />}
            </button>
          </div>
        </div>

        {/* Mobile Navigation */}
        {mobileMenuOpen && (
          <div className="md:hidden border-t-[3px] border-neo-navy py-4 space-y-2 bg-neo-cream">
            {navLinks.map((link) => {
              const isActive = location.pathname === link.path;
              const Icon = link.icon;

              return (
                <Link
                  key={link.path}
                  to={link.path}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`
                    block w-full px-4 py-3 font-heading font-bold text-sm uppercase tracking-wide
                    border-[2px] border-neo-navy transition-all duration-150
                    ${isActive
                      ? 'bg-neo-navy text-neo-cream shadow-none'
                      : 'bg-neo-cream text-neo-navy shadow-neo-sm hover:bg-neo-orange'
                    }
                  `}
                >
                  <span className="flex items-center justify-between">
                    <span className="flex items-center gap-2">
                      {Icon && <Icon className="w-4 h-4" />}
                      {link.label}
                    </span>
                    {link.highlight && (
                      <span className="text-[10px] px-2 py-0.5 bg-neo-orange text-neo-navy font-black border border-neo-navy">LIVE</span>
                    )}
                  </span>
                </Link>
              );
            })}

            {!loggedIn ? (
              <Link
                to="/login"
                onClick={() => setMobileMenuOpen(false)}
                className="block w-full px-4 py-3 font-heading font-bold text-sm uppercase tracking-wide border-[2px] border-neo-navy bg-neo-orange text-neo-navy shadow-neo-sm"
              >
                <span className="flex items-center gap-2">
                  <User className="w-4 h-4" />
                  Login
                </span>
              </Link>
            ) : (
              <div className="border-t-[2px] border-neo-navy/20 pt-2 space-y-1">
                {userMenuItems.map((item) => {
                  const Icon = item.icon;
                  return (
                    <button
                      key={item.path}
                      onClick={() => handleDropdownNavigate(item.path)}
                      className="flex items-center gap-2 w-full px-4 py-2.5 text-xs font-bold uppercase border-[2px] border-neo-navy/20 text-neo-navy hover:bg-neo-orange/15"
                    >
                      <Icon className="w-3.5 h-3.5" />
                      {item.label}
                    </button>
                  );
                })}
                <button
                  onClick={handleLogout}
                  className="flex items-center gap-2 w-full px-4 py-2.5 text-xs font-bold uppercase border-[2px] border-neo-maroon/30 text-neo-maroon hover:bg-neo-maroon/10"
                >
                  <LogOut className="w-3.5 h-3.5" />
                  Logout
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Logout Confirmation Modal */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-[100] flex items-center justify-center p-4">
          <div className="absolute inset-0 bg-neo-navy/60 backdrop-blur-sm" onClick={cancelLogout} />
          <div className="relative bg-neo-cream border-[3px] border-neo-navy shadow-neo p-6 w-full max-w-sm">
            <div className="flex flex-col items-center text-center">
              <div className="w-14 h-14 bg-neo-maroon/10 border-[3px] border-neo-maroon flex items-center justify-center mb-4">
                <AlertTriangle className="w-7 h-7 text-neo-maroon" />
              </div>
              <h3 className="font-heading font-bold text-lg text-neo-navy uppercase tracking-wide mb-1">
                Confirm Logout
              </h3>
              <p className="text-sm text-neo-navy/60 mb-6">
                Are you sure you want to log out of your session?
              </p>
              <div className="flex gap-3 w-full">
                <button
                  onClick={cancelLogout}
                  className="flex-1 px-4 py-2.5 font-heading font-bold text-xs uppercase tracking-wide border-[3px] border-neo-navy bg-neo-cream text-neo-navy hover:bg-neo-navy/5 transition-all duration-150"
                >
                  Cancel
                </button>
                <button
                  onClick={confirmLogout}
                  className="flex-1 px-4 py-2.5 font-heading font-bold text-xs uppercase tracking-wide border-[3px] border-neo-maroon bg-neo-maroon text-neo-cream hover:bg-neo-maroon/90 transition-all duration-150"
                >
                  <span className="flex items-center justify-center gap-1.5">
                    <LogOut className="w-3.5 h-3.5" />
                    Logout
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </nav>
  );
}
