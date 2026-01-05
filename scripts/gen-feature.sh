#!/bin/bash
# Generate a new feature scaffold

set -e

if [ -z "$1" ]; then
  echo "❌ Error: Feature name required"
  echo ""
  echo "Usage: pnpm gen:feature <feature-name>"
  echo ""
  echo "Example: pnpm gen:feature user-profile"
  exit 1
fi

FEATURE_NAME=$1
FEATURE_DIR="src/features/$FEATURE_NAME"

# Convert kebab-case to PascalCase for component names
# E.g., user-profile -> UserProfile
COMPONENT_NAME=$(echo "$FEATURE_NAME" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))} 1' OFS='')

# Convert kebab-case to camelCase for variable names
# E.g., user-profile -> userProfile
CAMEL_NAME=$(echo "$FEATURE_NAME" | awk -F'-' '{printf "%s", tolower($1); for(i=2;i<=NF;i++) printf "%s", toupper(substr($i,1,1)) tolower(substr($i,2))} END {print ""}')

# Check if feature already exists
if [ -d "$FEATURE_DIR" ]; then
  echo "❌ Error: Feature '$FEATURE_NAME' already exists at $FEATURE_DIR"
  exit 1
fi

echo "🏗️  Generating feature: $FEATURE_NAME"

# Create folder structure
mkdir -p "$FEATURE_DIR/components"
mkdir -p "$FEATURE_DIR/hooks"
mkdir -p "$FEATURE_DIR/routes"

# Create index file for components
cat > "$FEATURE_DIR/components/index.ts" << EOF
// Export all components from this feature
export * from './${COMPONENT_NAME}';
EOF

# Create main component file
cat > "$FEATURE_DIR/components/${COMPONENT_NAME}.tsx" << EOF
export function ${COMPONENT_NAME}() {
  return (
    <div>
      <h1>${COMPONENT_NAME}</h1>
      <p>Feature component ready. Start implementing!</p>
    </div>
  );
}
EOF

# Create index file for hooks
cat > "$FEATURE_DIR/hooks/index.ts" << EOF
// Export all hooks from this feature
// Example: export * from './use${COMPONENT_NAME}';
export {};
EOF

# Create routes file
cat > "$FEATURE_DIR/routes/index.tsx" << EOF
import { RouteObject } from 'react-router-dom';
import { ${COMPONENT_NAME} } from '../components';

export const ${CAMEL_NAME}Routes: RouteObject[] = [
  {
    path: '/$FEATURE_NAME',
    element: <${COMPONENT_NAME} />,
  },
];
EOF

# Create feature index
cat > "$FEATURE_DIR/index.ts" << EOF
export * from './components';
export * from './hooks';
export * from './routes';
EOF

echo "✅ Feature created at $FEATURE_DIR"
echo ""
echo "Created files:"
echo "  📁 $FEATURE_DIR/components/${COMPONENT_NAME}.tsx"
echo "  📁 $FEATURE_DIR/hooks/"
echo "  📁 $FEATURE_DIR/routes/"
echo ""
echo "Next steps:"
echo "  1. Add domain logic: pnpm gen:domain $FEATURE_NAME"
echo "  2. Implement components in $FEATURE_DIR/components/"
echo "  3. Add routes to router in src/app/router.tsx"
echo "  4. Run: pnpm check:all"
