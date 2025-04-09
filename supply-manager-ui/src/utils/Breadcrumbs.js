import React from 'react';

const Breadcrumbs = ({ breadcrumbs, onSelect }) => {
  return (
    <div style={{ marginBottom: '1rem' }}>
      {breadcrumbs
        .filter((crumb) => crumb && crumb.name)
        .map((crumb, index) => (
          <span key={crumb.id}>
            {index > 0 && ' > '}
            <button
              style={{
                background: 'none',
                border: 'none',
                color: index === breadcrumbs.length - 1 ? '#333' : '#007bff',
                cursor: 'pointer',
                textDecoration: index === breadcrumbs.length - 1 ? 'none' : 'underline',
              }}
              onClick={() => onSelect(crumb)}
            >
              {crumb.name}
            </button>
          </span>
        ))}
    </div>
  );
};

export default Breadcrumbs;