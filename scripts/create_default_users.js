const bcrypt = require('bcryptjs');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function main() {
  const password = '123';
  const passwordHash = await bcrypt.hash(password, 10);

  const users = [
    { username: 'admin', fullName: 'Administrator', role: 'admin' },
    { username: 'cashier', fullName: 'Cashier', role: 'cashier' },
    { username: 'viewer', fullName: 'Viewer', role: 'front_office' },
  ];

  for (const user of users) {
    const record = await prisma.user.upsert({
      where: { username: user.username },
      update: {
        passwordHash,
        fullName: user.fullName,
        role: user.role,
      },
      create: {
        username: user.username,
        passwordHash,
        fullName: user.fullName,
        role: user.role,
      },
    });

    console.log(`${record.username}: ${record.role} -> password set`);
  }
}

main()
  .catch((error) => {
    console.error('Failed to create default users:', error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
