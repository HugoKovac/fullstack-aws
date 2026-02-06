import {useAuth} from "react-oidc-context";
import {Card, Button, Box} from '@mantine/core';



export function ProfileForm() {
    const auth = useAuth();

    if (auth.isLoading) {
        return <div>Loading...</div>;
    }

    if (auth.error) {
        return <div>Encountering error... {auth.error.message}</div>;
    }

    return (
        <Box maw={400} h={100}>
            <Card shadow="sm" padding="lg" radius="md" withBorder>
                <div>
                    <pre> Hello: {auth.user?.profile.email} </pre>
                    <pre> ID Token: {auth.user?.id_token} </pre>
                    <pre> Access Token: {auth.user?.access_token} </pre>
                    <pre> Refresh Token: {auth.user?.refresh_token} </pre>
                </div>
                <Button onClick={() => auth.removeUser()} color="gray" fullWidth mt="md" radius="md">
                    Sign Out
                </Button>
            </Card>
        </Box>
    );
}
