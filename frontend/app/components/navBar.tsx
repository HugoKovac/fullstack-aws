import {
  Box,
  Burger,
  Button,
  Group,
  ScrollArea,
  Drawer,
  Divider,
  Text,
  NavLink,
} from "@mantine/core";
import { useDisclosure } from "@mantine/hooks";
import { useAuth } from "react-oidc-context";

export function NavBar() {
  const auth = useAuth();
  const [drawerOpened, { toggle: toggleDrawer, close: closeDrawer }] =
    useDisclosure(false);

  const signUpRedirect = () => {
    window.location.href =
      `${import.meta.env.VITE_COGNITO_DOMAIN}/signup?` +
      `client_id=${import.meta.env.VITE_COGNITO_CLIENT_ID}` +
      `&redirect_uri=${import.meta.env.VITE_DOMAIN}` +
      `&response_type=code` +
      `&scope=openid+email+profile` +
      `&screen_hint=signup`;
  };

  let account = undefined;
  if (auth.isAuthenticated) {
    account = (
      <Group justify="center">
        <NavLink href="/profile" label="Profile" />
      </Group>
    );
  } else {
    account = (
      <Group justify="center" visibleFrom="sm">
        <Button onClick={() => auth.signinRedirect()} color="blue" radius="md">
          Log in
        </Button>
        <Button onClick={() => signUpRedirect()} variant="outline" radius="md">
          Sign up
        </Button>
      </Group>
    );
  }

  return (
    <Box mt={"md"} pb="xl" px="md">
      <header>
        <Group justify="space-between" h="100%">
          <Text>Logo Here</Text>

          <Group h="100%" gap={0} visibleFrom="sm">
            <a href="#">Home</a>
            <a href="#">Learn</a>
            <a href="#">Academy</a>
          </Group>

          {account}

          <Burger
            opened={drawerOpened}
            onClick={toggleDrawer}
            hiddenFrom="sm"
            aria-label="Toggle navigation"
          />
        </Group>
      </header>

      <Drawer
        opened={drawerOpened}
        onClose={closeDrawer}
        size="100%"
        padding="md"
        title="Navigation"
        hiddenFrom="sm"
        zIndex={1000000}
      >
        <ScrollArea h="calc(100vh - 80px" mx="-md">
          <Divider my="sm" />

          <a href="#">Home</a>
          <a href="#">Learn</a>
          <a href="#">Academy</a>

          <Divider my="sm" />

          {account}
        </ScrollArea>
      </Drawer>
    </Box>
  );
}
