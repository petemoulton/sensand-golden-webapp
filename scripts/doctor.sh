#!/bin/bash
# Health check + setup validation

echo "🏥 Running health checks..."

FAILED=0

# Check Node version
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not installed"
  FAILED=1
else
  echo "✅ Node.js $(node --version)"
fi

# Check pnpm
if ! command -v pnpm &> /dev/null; then
  echo "❌ pnpm not installed. Run: npm install -g pnpm"
  FAILED=1
else
  echo "✅ pnpm $(pnpm --version)"
fi

# Check dependencies
if [ ! -d "node_modules" ]; then
  echo "❌ Dependencies not installed. Run: pnpm install"
  FAILED=1
else
  echo "✅ Dependencies installed"
fi

# Check TypeScript
if ! pnpm tsc --noEmit &> /dev/null; then
  echo "❌ TypeScript errors detected. Run: pnpm check:types"
  FAILED=1
else
  echo "✅ TypeScript valid"
fi

# Check circular dependencies
if pnpm madge --circular --extensions ts,tsx src | grep -q "✖ Found"; then
  echo "❌ Circular dependencies found. Run: pnpm check:circular"
  FAILED=1
else
  echo "✅ No circular dependencies"
fi

# Check ESLint
if ! pnpm eslint src --ext ts,tsx &> /dev/null; then
  echo "❌ Linting errors. Run: pnpm check:lint"
  FAILED=1
else
  echo "✅ Linting passed"
fi

if [ $FAILED -eq 1 ]; then
  echo ""
  echo "❌ Some checks failed. Fix issues above and re-run: pnpm doctor"
  exit 1
fi

echo ""
echo "✅ All checks passed! You're ready to develop."
echo ""
echo "Next steps:"
echo "  pnpm dev              # Start dev server"
echo "  pnpm gen:feature foo  # Create new feature"
echo "  pnpm help             # View START_HERE guide"
