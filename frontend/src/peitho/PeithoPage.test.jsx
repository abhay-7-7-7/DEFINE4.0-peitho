import { describe, it, expect } from 'vitest';
import React from 'react';
import ReactDOMServer from 'react-dom/server';
import { MemoryRouter } from 'react-router-dom';
import PeithoPage from './PeithoPage';
import { I18nProvider } from '../context/I18nContext';

describe('PeithoPage render', () => {
  it('renders to HTML string without throwing', () => {
    const html = ReactDOMServer.renderToString(
      <I18nProvider>
        <MemoryRouter>
          <PeithoPage />
        </MemoryRouter>
      </I18nProvider>
    );
    expect(html).toContain('PEITHO');
    expect(html).toContain('Configure Meet Assistant');
  });
});
