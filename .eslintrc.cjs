module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:react-hooks/recommended',
  ],
  ignorePatterns: ['dist', '.eslintrc.cjs'],
  parser: '@typescript-eslint/parser',
  plugins: ['react-hooks'],
  rules: {
    '@typescript-eslint/no-unused-vars': [
      'error',
      {
        argsIgnorePattern: '^_',
        varsIgnorePattern: '^_',
      },
    ],
    'no-restricted-imports': [
      'error',
      {
        paths: [
          {
            name: 'react',
            importNames: ['default'],
            message: 'Use named imports from React',
          },
        ],
        patterns: [
          {
            group: ['@features/*', 'src/features/*'],
            message: 'Features cannot import other features. Extract to @shared if needed.',
          },
        ],
      },
    ],
  },
  overrides: [
    {
      files: ['src/domain/**/*.{ts,tsx}'],
      rules: {
        'no-restricted-imports': [
          'error',
          {
            paths: [
              {
                name: 'react',
                message: 'Domain layer must be pure TypeScript (no React imports)',
              },
              {
                name: 'react-dom',
                message: 'Domain layer must be pure TypeScript (no React imports)',
              },
            ],
            patterns: [
              {
                group: ['@features/*', 'src/features/*'],
                message: 'Domain cannot import features',
              },
            ],
          },
        ],
      },
    },
    {
      files: ['src/shared/**/*.{ts,tsx}'],
      rules: {
        'no-restricted-imports': [
          'error',
          {
            patterns: [
              {
                group: ['@features/*', 'src/features/*'],
                message: 'Shared components cannot import features',
              },
            ],
          },
        ],
      },
    },
  ],
};
